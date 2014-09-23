package Bread::Board::LazyLoader::Supersite;
$Bread::Board::LazyLoader::Supersite::VERSION = '0.06';
use strict;
use warnings;

# ABSTRACT: loads the proper site with your Bread::Board setup


use Class::Load;
use Carp qw(croak);
use Module::Find qw(findsubmod);


sub _throw {
    croak join '', __PACKAGE__, '->import: ', @_, "\n";
}

sub import {
    my $this = shift;

    my $site = _find_site(@_);
    my %to_import = (
        site   => sub { $site },
        loader => sub { shift()->site->loader },
        root   => sub { shift()->site->root }
    );

    my $caller_package = caller;
    for my $method ( keys %to_import ) {
        no strict 'refs';
        *{ join '::', $caller_package, $method } = $to_import{$method};
    }
}

sub _load_site {
    my ( $site, $reason ) = @_;

    eval { Class::Load::load_class($site); };
    _throw sprintf "loading the site module %s%s failed:\n\n%s",
      $site, $reason ? " ($reason)" : '', $@
      if $@;
    return $site;
}

sub _find_site {
    my %args = @_;

    my $env_var = $args{env_var};
    if (my $site = $env_var && $ENV{$env_var}){
        return _load_site( $site, "contained in env var $env_var");
    }

    my $site = delete $args{site}
      or _throw "No site argument supplied";

    if (! ref $site ){
        return _load_site($site);
    }
    elsif ( ref $site eq 'HASH' ){
        # we select the only site which fulfills the condition
        my $prefix = $site->{prefix};
        my $filter = $site->{filter};

        $prefix && $filter or _throw "Invalid site argument $site";

        return _load_only_site($prefix, $filter);
    }
    else {
        _throw "Invalid site argument $site";
    }

}

# there must be just one site module $prefix:: conforming the selection
# for example Manggis::Site::<name> module where name starts with lowercase (cz, sk)
sub _load_only_site {
    my ($prefix, $filter) = @_;

    my $select =
        ref $filter eq 'Regexp' ? sub { $_ =~ $filter }
      : ref $filter eq 'CODE'  ? $filter
      :                       _throw "Inapropriate filter $filter";
    my @sites = grep {  
            my ($name) = /^${prefix}::(.*)/;
            local $_ = $name;
            $select->($name);
    } findsubmod($prefix);

    _throw "No site module $prefix\:\:* conforming your selection found\n" if !@sites;
    _throw "More than one site module $prefix\:\:* found (" . join( ', ', @sites ) . ')'
        if @sites > 1;
    return _load_site($sites[0], "found as the only proper $prefix\:\:* installed module");
}

1;

# vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=78:

__END__

=pod

=head1 NAME

Bread::Board::LazyLoader::Supersite - loads the proper site with your Bread::Board setup

=head1 VERSION

version 0.06

=head1 SYNOPSIS

    package MY::IOC;
    use strict;
    use warnings;

    use Bread::Board::LazyLoader::SuperSite env_var => 'MY_APP_SITE',
        site => {
            prefix => 'My::Site',
            filter => qr{^[a-z]}
        };

=head1 DESCRIPTION

This module is yet quite experimental.

=head1 AUTHOR

Roman Daniel <roman.daniel@davosro.cz>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Roman Daniel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
