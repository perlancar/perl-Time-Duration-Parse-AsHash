use inc::Module::Install;

name('Time-Duration-Parse');
all_from('lib/Time/Duration/Parse.pm');

requires('Exporter::Lite' => '0.02');
test_requires('Test::More' => '0.88');
test_requires('Time::Duration' => '1.06');

perl_version('5.006');
license('perl');
repository('https://github.com/neilbowers/Time-Duration-Parse');

auto_include;
WriteAll;
