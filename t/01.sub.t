use Test::More tests => 3;
use Term::ReadKey;

use SFC::SFS;

my $sfs = new SFC::SFS;

ok(defined($sfs), "new OK");

printf(stderr "\nEnter username: ");
chomp(my $username = <>);
printf(stderr "Enter password: ");
ReadMode('noecho');
chomp(my $password = <>);
printf(stderr "\n");

$sfs->set(cns_username => $username, cns_password => $password);
ok(defined($sfs->get_token()), "get_token OK");
ok(defined($sfs->get_timetable()), "get_timetable OK");

