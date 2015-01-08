package Bread::Board::LazyLoader::Container;
$Bread::Board::LazyLoader::Container::VERSION = '0.09';
use Moose;

# ABSTRACT: building subcontainers lazily

extends 'Bread::Board::Container';
with 'Bread::Board::LazyLoader::Role::Container';

__PACKAGE__->meta->make_immutable;
1;

# vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=78: 

__END__

=pod

=encoding UTF-8

=head1 NAME

Bread::Board::LazyLoader::Container - building subcontainers lazily

=head1 VERSION

version 0.09

=head1 AUTHOR

Roman Daniel <roman.daniel@davosro.cz>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Roman Daniel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
