package SFC::SFS;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.1');

use utf8;
use Encode;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new();
my $base = "vu8.sfc.keio.ac.jp/sfc-sfs";

sub new {
    my ($class, %args) = (@_);

    return bless \%args, $class;
}

sub set {
    my ($thys, %args) = (@_);

    foreach my $key (%args) {
        $thys->{$key} = $args{$key};
    }

    return 1;
}

sub get_token {
    my ($thys, %args) = (@_);

    $thys->set(%args);

    unless(exists($thys->{cns_username}) && length($thys->{cns_username})) {
        die('CNS Username not specified')
    }

    unless(exists($thys->{cns_password}) && length($thys->{cns_password})) {
        die('CNS Password not specified')
    }

    my $url = sprintf("http://%s/login.cgi?u_login=%s&u_pass=%s",
                      $base, $thys->{cns_username}, $thys->{cns_password});

    my $res = $ua->get($url);

    unless($res->is_success) {
        die($res->status_line);
    }

    my $token = $res->decoded_content;

    unless($token =~ s/^.+id=([\d\w]+?)&.+$/$1/g) {
        die("Unable to authenticate user");
    }

    $thys->{token} = $token;

    return $token;
}

sub get_timetable {
    my ($thys, %args) = (@_);

    $thys->set(%args);

    unless(exists($thys->{token}) && length($thys->{token})) {
        $thys->get_token();
    }

    my $url = sprintf("http://%s/sfs_class/student/view_timetable.cgi?id=%s".
      "&term=2014s&fix=0&lang=ja", $base, $thys->{token});

    my $res = $ua->get($url);

    unless($res->is_success) {
        die($res->status_line);
    }

    my $html = $res->decoded_content;
    my $table;
    my $i = 0;

    foreach my $tr ($html =~ m/<tr valign="top" bgcolor="#eeeeee">.+<\/tr>/g) {
        my $j = 0;
        foreach my $td ($tr =~ m/<td .+?<\/td>/g) {
            my $tmp = undef;
            if($td =~ /<a href="(.+?)" .+?>(.+?)\[(.+)\]<\/a><br>\( (.+?) \)<br>/) {
                $tmp = {
                    url => $1,
                    name => $2,
                    room => $3,
                    teacher => $4
                   };
            }
            $table->[$j]->[$i] = $tmp;
            $j++;
            last if $j == 5;
        }
        $i++;
    }

    $thys->{timetable} = $table;

    return $table;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

SFC::SFS - [One line description of module's purpose here]


=head1 VERSION

This document describes SFC::SFS version 0.0.1


=head1 SYNOPSIS

    use SFC::SFS;

    my $sfs = SFC::SFS->new(cns_username => hoge, cns_password => fuga);
    my $token = $sfs->get_token();


=head1 DESCRIPTION

=head2 $sfs = SFC::SFS->new()

    Name: $sfs = SFC::SFS->new() - create an instance of SFC-SFS

    This module is a simple interface to access information from SFC-SFS.

    Mandatory qualifiers:
        cns_username - CNS username to access.
        cns_password - CNS password to access.

=head2 SFC::SFS->get_token()
    Retrieves a session token for the authenticating user.

=head2 SFC::SFS->get_timetable()
    Retrieves the timetable for the authenticating user.

=head2 SFC::SFS->set()
    An interface for setting a property.


=head1 INTERFACE 

Constructor:
$sfs = SFC::SFS->new(<arguments>);


=head1 DIAGNOSTICS

=over

=item C<< CNS Username not specified >>

The CNS username for authentication is not set.
Try setting a proper value.

=item C<< CNS Password not specified >>

The CNS password for authentication is not set.
Try setting a proper value.

=item C<< Unable to authenticate user >>

Either the username or the password is wrong.

=back

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
SFC::SFS requires no configuration files or environment variables.


=head1 DEPENDENCIES

LWP::UserAgent
Encode


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS


No bugs have been reported.

Please report any bugs or feature requests to
C<t11080hi@sfc.keio.ac.jp>.


=head1 AUTHOR

kotone  C<< <t11080hi@sfc.keio.ac.jp> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, kotone C<< <t11080hi@sfc.keio.ac.jp> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
