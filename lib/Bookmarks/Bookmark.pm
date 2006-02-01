package Bookmarks::Bookmark;
use base 'Class::Accessor';
use warnings;

Bookmarks::Bookmark->mk_accessors(qw/created modified visited charset url name
                                     id personal icon description expanded
                                      trash order type/);


