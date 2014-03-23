use inc::Module::Install;

name('Time-Duration-Parse');
all_from('lib/Time/Duration/Parse.pm');

requires('Exporter::Lite');
build_requires('Test::More');
build_requires('Time::Duration');

perl_version('5.006');
license('perl');
repository 'https://github.com/neilbowers/Time-Duration-Parse';

auto_include;
WriteAll;
