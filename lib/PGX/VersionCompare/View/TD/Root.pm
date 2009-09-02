package PGX::VersionCompare::View::TD::Root;

use strict;
use warnings;
use feature ':5.10';

use Data::Dumper;
use List::Util qw( first );
use Template::Declare::Tags;

=head1 Name

PGX::VersionCompare::View::TD::Root - Root TD templates

=head1 Description

This module contains the Template::Declare templates used
by PGX::VersionCompare.  For the programming logic behind them, see
PGX::VersionCompare::Controller::Root (for the index template) and
PGX::VersionCompare::Controller::Compare (for all other templates).

In general, the name of the template is the name of the Controller method,
so a template named index matches sub index.  One exception is
PGX::VersionCompare::Controller::Compare->compare, which sets the
template conditionally based on its input parameters:  either

$c->stash(template => 'compare') # If there is no input

or

$c->stash(template => 'compare_result'); # If there is input

=head1 Templates

=head2 wrap

  template foo => sub {
      my ($self, $c) = @_;
      wrap {
          h1 { 'Welcome!' };
      } $c;
  };

Wrapper template used by all page view templates to output the XHTML that's
common to every page view.

=cut

BEGIN {
    create_wrapper wrap => sub {
        my ($code, $c, %p) = @_;
        outs_raw '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" '
                . '"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">';
        html {
            attr { xmlns => 'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en' }
            head {
                title { $c->config->{name} . ': ' . $c->stash->{title} };
                link { attr {
                    href => '/ui/css/screen.css',
                    type => 'text/css',
                    rel  => 'stylesheet'
                } };
            };
            body {
                div {
                    id is 'ccn';
                    div {
                        id is 'con';
                        img {
                            id  is 'lgo';
                            src is '/ui/img/logo.png';
                            alt is 'PostgreSQL Experts, Inc.'
                        };
                        div {
                            id is 'cnt';
                            $code->();
                        };
                    };
                };
                div {
                    id is 'ft';
                    div {
                        id is 'ftr';
                        span {
                            '© ' . ((localtime(time))[5] + 1900)
                                   . ' PostgreSQL Experts Inc.';
                        };
                        a { href is '#'; 'Privacy Policy' }
                        a { href is '#'; 'Terms of Use' }
                        span {
                            a {
                                href is 'mailto:sales@pgexperts.com';
                                'sales@pgexperts.com';
                            };
                        };
                        span { '+1 888 PG-EXPRT (743-9778)' };
                    };
                };
            };
        };
    };
}

=head2 with_query_section

  template foo => sub {
      my ($self, $c) = @_;
      with_query_section {
          div {
              id is 'stuff_that_goes_below_the_form_element';
              ...
          };
      } $c;
  };

with_query_section is a template that applies the wrapper 'wrap', then
adds a query form, with sticky fields, where the user inputs the version
numbers and (optional) search expression to look for.

with_query_section is used by the 'compare' template and the 'compare_result'
template to keep those pages DRY.

=cut
BEGIN {
    create_wrapper with_query_section => sub {
        my ($code, $c, %p) = @_;

        # Get sticky values, if form already has been submitted
        my $major_1 = first {defined $_} $c->{stash}->{major_1}, '';
        my $major_2 = first {defined $_} $c->{stash}->{major_2}, '';
        my $minor_1 = first {defined $_} $c->{stash}->{minor_1}, '';
        my $minor_2 = first {defined $_} $c->{stash}->{minor_2}, '';

        my $known_versions_ref = $c->stash->{known_versions_ref};
        my @major_versions = sort keys %{ $known_versions_ref };
        
        wrap {
            form {
                id is 'query';
                action is '/form_handler';
                method is 'post';
                
                p { 'fixes from' };
                select {
                    name is 'major_1';
                    for my $major_version (@major_versions) {
                        option {
                            selected is 'selected'
                                if $major_1 eq $major_version; ## no critic
                            $major_version;
                        };
                    }
                };
                span { class is 'dot'; '.'; };
                select {
                    name is 'minor_1';
                    #FIXME:  Replace this incorrect stub with JS that fills out the options dependent on the value of major_1 select!!!!  Use JS.
                    for my $minor_version (0 .. 21) {
                        option {
                            selected is 'selected'
                                if $minor_1 eq $minor_version; ## no critic
                            $minor_version;
                        };
                    }
                };

                p{ 'to' };
                select {
                    name is 'major_2';
                    for my $major_version (@major_versions) {
                        option {
                            selected is 'selected'
                                if $major_2 eq $major_version; ## no critic
                            $major_version;
                        };
                    }
                };
                span { class is 'dot'; '.'; };
                select {
                    name is 'minor_2';
                    #FIXME:  Replace this incorrect stub with JS that fills out the options dependent on the value of major_2 select!!!!  Use JS.
                    for my $minor_version (0 .. 21) {
                        option {
                            selected is 'selected'
                                if $minor_2 eq $minor_version; ## no critic
                            $minor_version;
                        };
                    }
                };

                div {
                    id is 'search';
                    p { 'matching' };
                    input { type is 'text'; name is 'q' };
                };
                
                button {
                    type is 'submit';
                    'Show'
                };
            };

            $code->();
        } $c;
    };
}

=head2 index

Simple test template.  Just shows <h1>Welcome</h1>, wrapped with the PG Experts header and footer.  #FIXME:  Make this template invisible to the user.

For now, that's all.  Maybe someday we will replace this with the code from
the compare template here, so you can do http://example.com/8.1.1/8.1.2
rather than http://example.com/compare/8.1.1/8.1.2

=cut
template index => sub {
    my ($self, $c) = @_;
    wrap {
        h1 { 'Welcome' };
    } $c;
};

=head2 compare

compare - show the search form, without results.

=cut
template compare => sub {
    my ($self, $c) = @_;
    with_query_section {} $c;
};

=head2 compare_results

compare_results - show the search form, with results unpacked from the
database (via the $various_sth variables).

=cut
template compare_result => sub {
    my ($self, $c) = @_;
    my $fixes_sth = $c->{stash}->{fixes_sth};
    
    with_query_section {
        div {
            id is 'result';

            div {
                id is 'fixes';
                p { 'fixes' }; # FIXME:  If no fixes, say 'no diffs found'
                table {
                    class is 'fixes';
                    #FIXME:  When there are 0 results (e.g. when you use a search term that doesn't match anything), you get this:  <table class="fixes">0</table>.  WTF?  Template::Declare quirk?
                    while (my ($version, $fix) = $fixes_sth->fetchrow_array()) {
                        row {
                            cell {$version}; cell {$fix};
                        };
                    }
                };
            };
        };

    } $c;
};

1;

__END__

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut
