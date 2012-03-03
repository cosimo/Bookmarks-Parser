use Test::More tests => 4;
use Data::Dumper;

use Bookmarks::Parser;

my $parser = Bookmarks::Parser->new();
my $bookmarks = $parser->parse({filename => 't/rt75463.adr'});
ok($bookmarks, "Test file loaded correctly");

my @roots = $parser->get_top_level();
my $pysidebar = $roots[0];

is(
    $pysidebar->{url}, 'http://www.edgewall.org/python-sidebar/html/toc-tutorial.html',
    'Loaded the python sidebar bookmark',
);

is(
    $pysidebar->{in_panel}, 'YES',
    "#75436: IN PANEL property is parsed correctly",
);

is(
    $pysidebar->{panel_pos}, 9,
    "#75436: PANEL_POS property is parsed correctly",
);

#
# End of test
