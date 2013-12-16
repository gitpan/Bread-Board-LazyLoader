package Bread::Board::LazyLoader::Container;
{
  $Bread::Board::LazyLoader::Container::VERSION = '0.03';
}
use Moose::Role;

# ABSTRACT: building subcontainers lazily

use List::MoreUtils qw(uniq);

# builder for a sub_container 
has sub_builders => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
    traits  => ['Hash'],
    handles => {
        has_sub_builder      => 'exists',
        get_sub_builder_list => 'keys',
    },
);

around has_sub_container => sub {
    my ( $orig, $this, $name ) = @_;

    return $orig->( $this, $name ) || $this->has_sub_builder($name);
};

around get_sub_container_list => sub {
    my ( $orig, $this ) = @_;

    return uniq $orig->($this), $this->get_sub_builder_list;
};

around get_sub_container => sub {
	my ($orig, $this, $name) = @_;

    my $sub_container = $orig->($this, $name);

    if ( my $builder = delete $this->sub_builders->{$name}){
        # if there is a builder we apply it to returned value
        $sub_container = $builder->build($sub_container);
        # and replace the sub_container
        $this->add_sub_container( $sub_container );
    }

    return $sub_container;
};

1;

# vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=78: 

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::LazyLoader::Container - building subcontainers lazily

=head1 VERSION

version 0.03

=head1 AUTHOR

Roman Daniel <roman.daniel@davosro.cz>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Roman Daniel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
