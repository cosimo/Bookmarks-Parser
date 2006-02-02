use lib 'lib';
use Test::More 'no_plan';
use Data::Dumper;

# 1 test load of base class
use_ok('Bookmarks::Parser');

# 2 parse opera style file
my $parser = Bookmarks::Parser->new();
$parser->parse({filename => 't/opera6.adr'});
isa_ok($parser, 'Bookmarks::Opera');

# 3 check root items exist
my @roots = $parser->get_top_level();
is_deeply([ map { $_->{name} } @roots ], 
            ['Trash', 'Opera', 'Download.com', 'Amazon.com', 'Dealtime.com', 'eBay'], 'Found root items');

# 4,5 check we parsed subitems
my @subitems = $parser->get_folder_contents($roots[1]);
is($subitems[0]->{url}, 'http://www.opera.com/download/', 'Found first subitem');
is($subitems[-1]->{url}, 'http://www.opera.com/support/', 'Found last subitem');
# 6 create new opera bookmarks
my $opera = Bookmarks::Opera->new();
isa_ok($opera, 'Bookmarks::Opera');

# 7 set the root item(s)
$opera->set_top_level('root folder');
@roots = $opera->get_top_level();
is($roots[0]->{name}, 'root folder', 'Set root items');

# 8 rename the root folder
is($opera->rename($roots[0], 'new root folder'), 
   'new root folder', 'Renamed root item');

# 9 set title
is($parser->set_title('Opera Bookmarks'), 'Opera Bookmarks');

# 10 change to netscape
my $netscape = $parser->as_netscape();
isa_ok($netscape, 'Bookmarks::Netscape');

# 11 output as netscape
my $netscapefile = $netscape->as_string();
# print $operafile;


my $xmlparser = $parser->as_xml();
isa_ok($xmlparser, 'Bookmarks::XML');
my $xmlfile = $xmlparser->as_string();
# print $xmlfile;
