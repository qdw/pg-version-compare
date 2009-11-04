#!/usr/bin/perl -w
use strict;
use DBI;

my @sgmlfiles = @ARGV;
my $mode = "filler";
my ( $dbname, $dbuser, $dbpass ) = ( "versions", "josh", undef );

my $pdbh = DBI->connect(
    "dbi:Pg:dbname=$dbname",
    $dbuser,
    $dbpass,
    {
        AutoCommit => 0,
        RaiseError => 0,
    }
);

# clear out the database
$pdbh->do('TRUNCATE versions CASCADE;');

foreach my $sgmlfile ( @sgmlfiles ) {
    
    my @version;
    my ( $fix, $migration, $sql ) = ( "","", "" );

    open NOTES, "<", $sgmlfile or die "Could not open release notes $sgmlfile \n";
    
    while (<NOTES>) {
        my $line = $_;
        if ( $line =~ /<title>(.*\w+.*)<\/title>/ ) {
            #oooh, a title.  This may change our mode
            my $title = $1;
            if ( $title =~ /^Release\s+(\d+\.\d+(?:\.\d+)?)/) {
                #it's a release title, change modes and set the release version
                $fix = write_fix ( \@version, $fix, $pdbh );
                $migration = write_migration (\@version, $migration, $pdbh );
                @version = split(/\./, $1);
                $version[2] = "0" unless defined $version[2];
                create_version ( \@version, $pdbh);
                $mode = "filler";
            } elsif ( $title =~ /Migration to Version/) {
                #it's a migration notice.  write out fixes, set that mode and continue
                $fix = write_fix ( \@version, $fix, $pdbh );
                $line = "";
                $mode = "migration";
            } elsif ( $title =~ /Changes/ ) {
                #now we're in looking for fixes mode.  set that mode, and write out any migrations
                $migration = write_migration ( \@version, $migration, $pdbh );
                $mode = "findfix";
            } else {
                #some other title.  change to filler mode and write out buffers
                $migration = write_migration ( \@version, $migration, $pdbh );
                $fix = write_fix ( \@version, $fix, $pdbh );
                $mode = "filler";
            }
        }
        #what mode are we in?
        if ( $mode eq "migration" ) {
            #we're in migration mode.  Keep appending lines onto the block
            $migration .= $line;
        } elsif ( $mode eq "findfix" ) {
            #we're looking for the first fix.  find the start lineitem
            if ( $line =~ /<listitem>/ ) {
                $mode = "fix";
            }
        } elsif ( $mode eq "fix" ) {
            #we're in fix mode.  start accumulating fixes.
            #break each time we hit a listitem break
            if ( $line =~ /<\/listitem>/ ) {
                $fix = write_fix (\@version, $fix, $pdbh);
            } else {
                $fix .= $line;
            }
        }
        #otherwise, we're in filler mode and ignore everthing else
    }
    
    #end of file, make sure we clear out any pending writes
    write_fix(\@version, $fix, $pdbh);
    write_migration(\@version, $migration, $pdbh);

}

#we've loaded all the versions, time to do some cleanup.
#delete all duplicate migrations
$pdbh->do("update versions set upgrade_warning = ''
where upgrade_warning in (select upgrade_warning from versions
v2 group by upgrade_warning having count(*) > 1);");

#disconnect
$pdbh->commit();
$pdbh->disconnect();

print "version information loaded into the database.\n";
exit (0);

sub create_version {
    my ( $wversion, $dbh ) = @_;
    my $sql = 'INSERT INTO versions ( super, major, minor ) VALUES ( ?, ?, ? )';
    my $sth = $dbh->prepare($sql);
    $sth->execute($wversion->[0], $wversion->[1], $wversion->[2])
        or die "version insert failed ", @{$wversion}, "\n";
    $sth->finish;
}

sub write_migration {
    my ( $wversion, $wmigration, $dbh ) = @_;
    
    #clean out any sgml tags
    $wmigration =~ s/<[^>]*>/ /g;
    #replace all double spaces, line breaks etc with single spaces
    $wmigration =~ s/\s+/ /gm;
    #if anything left to write, write it    
    if ( $wmigration ) {
        my $sql = 'UPDATE versions SET upgrade_warning = btrim(?) WHERE super = ? AND major = ? and minor = ?';
        my $sth = $dbh->prepare($sql);
        $sth->execute($wmigration, $wversion->[0], $wversion->[1], $wversion->[2])
            or die "migration failed ", @{$wversion}, ":  ($wmigration)\n";
        $sth->finish;
    }
    return "";
    #return a "" to blank out the migration
}

sub write_fix {
    my ( $wversion, $wfix, $dbh ) = @_;
    
    #clean out any sgml tags
    $wfix =~ s/<[^>]*>/ /g;
    #replace all double spaces, line breaks etc with single spaces
    $wfix =~ s/\s+/ /gm;
    $wfix =~ s/^\s+//g;
    $wfix =~ s/\s+$//g;
    #if there's anything to write, write it
    if ( $wfix ) {
        #write the fix
        my $sql = 'INSERT INTO fixes ( super, major, minor, fix_desc, fix_md5, fix_tsv ) VALUES ( ?,?,?,?, md5(?), to_tsvector(?) );';
        my $sth = $dbh->prepare($sql);
        $sth->execute($wversion->[0], $wversion->[1], $wversion->[2], $wfix, $wfix, $wfix)
            or die "fix failed ", @{$wversion}, ":  ($wfix)\n";
        $sth->finish;
    }
    return "";
    #return a "" to blank out the fix
}
