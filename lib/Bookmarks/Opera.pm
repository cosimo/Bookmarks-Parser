#!/usr/bin/perl

package Bookmarks::Opera;
# use Bookmarks::Parser;
use base 'Bookmarks::Parser';
use warnings;

my %bookmark_fields = (
  'created'       => 'created',
  'modified'      => undef,
  'visited'       => 'visited',
  'charset'       => undef,
  'url'           => 'url',
  'name'          => 'name',
  'id'            => 'id',
  'personal'      => undef,
  'icon'          => 'iconfile',
  'description'   => 'description',
  'expanded'      => 'expanded',
  'trash'         => 'trash folder',
  'order'         => 'order',
                       );


sub _parse_file
{
    my ($self, $filename) = @_;

    return undef if(!-e $filename);

    my $fh;
    my $curitem   = {};
    my $curfolder = {};
    open $fh, "<$filename" or die "Can't open $filename ($!)";

    while (my $line = <$fh>)
    {
#        chomp $line;
        $line =~ s/[\r\n]//g;
        next if($line =~ /^Opera Hotlist version/);
        next if($line =~ /^Options:/);

        if($line eq '')
        {
            if($curitem->{start})
            {
#                print Dumper($curitem);
                delete $curitem->{start};
                $curitem->{parent} = $curfolder->{id};
#                $curitem->{parent} = exists $curfolder->{id} 
#                                      ? $curfolder->{id} : 'root';
#                push @{$self->{_itemlist}}, $curitem->{id};
#                push @{$self->{_items}{$curitem->{parent}}{children}}, $curitem->{id};
#                $self->{_items}{$curitem->{id}} = $curitem;

                $self->add_bookmark($curitem, $curfolder->{id});
                
                if($curitem->{type} eq 'folder')
                {
                    $curfolder = $curitem;
                }
                $curitem = {};
            }
        }
        if($line eq '-')
        {
            $curfolder = $self->{_items}{$curfolder->{parent}};
#            ($curfolder) = grep { $_->{id} eq $curfolder->{parent} } 
#                                     @{$self->{_items}};
        }
        if($line =~/^#(FOLDER|URL)/)
        {
            $curitem->{start} = 1;
            $curitem->{type}  = lc($1);
        }
        if($curitem->{start})
        {
            $curitem->{ name       } = $1 if($line =~ /\s+NAME=(.*)/       );
            $curitem->{ id         } = $1 if($line =~ /\s+ID=(\d+)/        );
            $curitem->{ created    } = $1 if($line =~ /\s+CREATED=(\d+)/   );
            $curitem->{ url        } = $1 if($line =~ /\s+URL=(.*)/        );
            $curitem->{ visited    } = $1 if($line =~ /\s+VISITED=(\d+)/   );
            $curitem->{ icon       } = $1 if($line =~ /\s+ICONFILE=(.*)/   );
            $curitem->{ description} = $1 if($line =~ /\s+DESCRIPTION=(.*)/);
            $curitem->{ order      } = $1 if($line =~ /\s+ORDER=(\d+)/     );
            $curitem->{ expanded   } = $1 if($line =~ /\s+EXPANDED=(.*)/   );
        }
    }
        
    close($fh);
    return $self;
}

sub get_header_as_string
{
    my ($self) = @_;

    my $header = << "HEADER";
Opera Hotlist version 2.0
Options: encoding = utf8, version=3

HEADER

    return $header;
}

{
    my $folorder = 0;

    sub get_item_as_string
    {
        my ($self, $item) = @_;
        
        if(!defined $item->{id} || !$self->{_items}{$item->{id}})
        {
            warn "No such item in get_item_as_string";
            return;
        }
        
        my $string = '';
        my ($id, $url, $name, $visited, $created, $modified, $icon, $desc, $expand, $trash, $order) =
            ($item->{id} || 0,
             $item->{url} || '',
             $item->{name} || '',
             $item->{visited} || 0,
             $item->{created} || time(),
             $item->{modified} || 0,
             $item->{icon} || '',
             $item->{description} || '',
             $item->{expanded} || '',
             $item->{trash} || '',
             $item->{order} || undef);
        
        if($item->{type} eq 'folder')
        {
            if(!defined($order))
            {
                $folorder = 0;
            }
            $string .= "#FOLDER\n";
            $string .= "        ID=$id\n";
            $string .= "        NAME=$name\n";
            $string .= "        CREATED=$created\n";
            $string .= "        TRASH FOLDER=$trash\n" if($trash);
            $string .= "        VISITED=$visited\n"    if($visited);
            $string .= "        EXPANDED=$expand\n"    if($expand);
            $string .= "        DESCRIPTION=$desc\n"   if($desc);
            $string .= "        ICONFILE=$icon\n"      if($icon);
            $string .= "        ORDER=$order\n"        if(defined $order);
            $string .= "\n";
            
            $string .= $self->get_item_as_string($self->{_items}{$_})
                foreach (@{$item->{children}});
            $string .= "-\n";
        } 
        elsif($item->{type} eq 'url')
        {
            if(!defined($order))
            {
                $order = $folorder++;
            }
                
            $string .= "#URL\n";
            $string .= "        ID=$id\n";
            $string .= "        NAME=$name\n";
            $string .= "        URL=$url\n"            if($url);
            $string .= "        CREATED=$created\n";
            $string .= "        TRASH FOLDER=$trash\n" if($trash);
            $string .= "        VISITED=$visited\n"    if($visited);
            $string .= "        EXPANDED=$expand\n"    if($expand);
            $string .= "        DESCRIPTION=$desc\n"   if($desc);
            $string .= "        ICONFILE=$icon\n"      if($icon);
            $string .= "        ORDER=$order\n"        if(defined $order);
            $string .= "\n";
        }
        
        return $string;
    }
}

1;

__END__

=head1 NAME 

Bookmarks::Opera - Opera style bookmarks.

=head1 SYNOPSIS

=head1 DESCRIPTION

A subclass of L<Bookmarks::Parser> for handling Opera bookmarks.

=head1 METHODS

=head2 get_header_as_string

=head2 get_item_as_string

=head2 get_footer_as_string

See L<Bookmarks::Parser> for these methods.

=head1 AUTHOR

Jess Robinson <castaway@desert-island.demon.co.uk>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
