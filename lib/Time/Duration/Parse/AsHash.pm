package Time::Duration::Parse::AsHash;

# DATE
# VERSION

#IFUNBUILT
use strict;
use warnings;
#IFUNBUILT

use Exporter;
our @ISA    = qw( Exporter );
our @EXPORT = qw( parse_duration );

my %Units = ( map(($_, "nanoseconds" ), qw(ns nanosecond nanoseconds)),
              map(($_, "milliseconds"), qw(ms millisecond milliseconds milisecond miliseconds)),
              map(($_, "microseconds"), qw(microsecond microseconds)),
              map(($_, "seconds"), qw(s second seconds sec secs)),
              map(($_, "minutes"), qw(m minute minutes min mins)),
              map(($_,   "hours"), qw(h hr hour hours)),
              map(($_,    "days"), qw(d day days)),
              map(($_,   "weeks"), qw(w week weeks)),
              map(($_,  "months"), qw(M month months mon mons mo mos)),
              map(($_,   "years"), qw(y year years)),
              map(($_, "decades"), qw(decade decades)),
          );
my %Converts = (
    nanoseconds  => ["seconds" => 1e-9],
    microseconds => ["seconds" => 1e-6],
    milliseconds => ["seconds" => 1e-3],
    decades      => ["years"   => 10],
);

sub parse_duration {
    my $timespec = shift;

    # You can have an optional leading '+', which has no effect
    $timespec =~ s/^\s*\+\s*//;

    # Treat a plain number as a number of seconds (and parse it later)
    if ($timespec =~ /^\s*(-?\d+(?:[.,]\d+)?)\s*$/) {
        $timespec = "$1s";
    }

    # Convert hh:mm(:ss)? to something we understand
    $timespec =~ s/\b(\d+):(\d\d):(\d\d(?:\.\d+)?)\b/$1h $2m $3s/g;
    $timespec =~ s/\b(\d+):(\d\d)\b/$1h $2m/g;

    my %res;
    while ($timespec =~ s/^\s*(-?\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)(?:\s*(?:,|and)\s*)*//i) {
        my($amount, $unit) = ($1, $2);
        $unit = lc($unit) unless length($unit) == 1;

        if (my $canon_unit = $Units{$unit}) {
            $amount =~ s/,/./;
            if (my $convert = $Converts{$canon_unit}) {
                $canon_unit = $convert->[0];
                $amount *= $convert->[1];
            }
            $res{$canon_unit} += $amount;
        } else {
            die "Unknown timespec: $1 $2";
        }
    }

    if ($timespec =~ /\S/) {
        die "Unknown timespec: $timespec";
    }

    for (keys %res) {
        delete $res{$_} if $res{$_} == 0;
    }

    if ($_[0]) {
        return
            ( $res{seconds} || 0) +
            (($res{minutes} || 0) *      60) +
            (($res{hours}   || 0) *    3600) +
            (($res{days}    || 0) *   86400) +
            (($res{weeks}   || 0) * 7*86400) +
            (($res{months} || 0) * 30*86400) +
            (($res{years} || 0) * 365*86400);
    }

    \%res;
}

1;
# ABSTRACT: Parse string that represents time duration

=head1 SYNOPSIS

  use Time::Duration::Parse::AsHash;

  my $res = parse_duration("2 minutes and 3 seconds");    # => {minutes=>2, seconds=>3}
     $res = parse_duration("2 minutes and 3 seconds", 1); # => 123


=head1 DESCRIPTION

Time::Duration::Parse::AsHash is like L<Time::Duration::Parse> except:

=over

=item * By default it returns a hashref of parsed duration elements instead of number of seconds

There are some circumstances when you want this, e.g. when feeding into
L<DateTime::Duration> and you want to count for leap seconds.

To return number of seconds like Time::Duration::Parse, pass a true value as the
second argument.

=item * Seconds are not rounded by default

For example: C<"0.1s"> or C<100ms> will return result C<< { seconds => 0.1 } >>.

Also, in addition to C<01:02:03> being recognized as C<1h2min3s>,
C<01:02:03.4567> will also be recognized as C<1h2min3.4567s>.

=item * Extra elements recognized

C<milliseconds> (or C<ms>). This will be returned in C<seconds> key.

C<microseconds>. This will also be returned in C<seconds> key.

C<nanoseconds> (or C<ns>). This will also be returned in C<seconds> key.

C<decades>. This will be returned in C<years> key.

=item * It has a lower startup overhead

By avoiding modules like L<Carp> and L<Exporter::Lite>, even L<strict> and
L<warnings>.

=back


=head1 FUNCTIONS

=head2 parse_duration($str [, $as_secs ]) => hash

Parses duration string and returns hash (unless when the second argument is
true, in which case will return the number of seconds). Dies on parse failure.
This function is exported by default.

Note that number of seconds is an approximation: leap seconds are not regarded
(so a minute is always 60 seconds), a month is 30 days, a year is 365 days.


=head1 SEE ALSO

L<Time::Duration::Parse>
