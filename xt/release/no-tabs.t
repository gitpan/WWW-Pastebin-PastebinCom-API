use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::NoTabsTests 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/WWW/Pastebin/PastebinCom/API.pm',
    't/00-compile.t',
    't/00-load.t',
    't/01-paste.t'
);

notabs_ok($_) foreach @files;
done_testing;
