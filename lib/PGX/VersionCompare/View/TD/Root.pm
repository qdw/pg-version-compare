package PGX::VersionCompare::View::TD::Root;

use strict;
use warnings;
use feature ':5.10';

use Template::Declare::Tags;

=head1 Name

PGX::VersionCompare::View::TD::Root - Root TD templates

=head1 Description

This module contains the Template::Declare templates used by PGX::VersionCompare.

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

=head2 index

=cut

template index => sub {
    my ($self, $c) = @_;
    wrap {
        h1 { 'Welcome' };
    } $c;
};

template version => sub {
    my ($self, $c) = @_;
    my $v1 = $c->stash->{v1};
    my $v2 = $c->stash->{v2};

=for later
    if (!defined $v1 && !defined $v2) {
        # No input given.  That means we present the query section only.
    }
    elsif (defined $v1 && defined $v2) {
        # Two versions given.  That means we present the same query section
        # with those values filled in ("sticky"-style), and then, below it,
        # show the changes between those versions.
    }
    else {
        $c->error(<<'END_ERR');
In order to compare versions, you must provide two version numbers.  You provided only one.
END_ERR
    }
=cut

#=for deletion soon
    wrap {
        h1 { 'Compare controller' };
    } $c;
#=cut

};

1;

=head1 Authors

=over

=item * Josh Berkus <josh.berkus@pgexperts.com>

=item * David E. Wheeler <david.wheeler@pgexperts.com>

=item * Quinn Weaver <quinn.weaver@pgexperts.com>

=back

=head1 Copyright

Copyright (c) 2009 PostgreSQL Experts, Inc. All Rights Reserved.

=cut
