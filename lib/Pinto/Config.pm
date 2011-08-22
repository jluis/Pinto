package Pinto::Config;

# ABSTRACT: Internal configuration for a Pinto repository

use Moose;

use MooseX::Configuration;

use MooseX::Types::Moose qw(Str Bool Int);
use Pinto::Types 0.017 qw(URI Dir);

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------
# Moose attributes

has repos   => (
    is        => 'ro',
    isa       => Dir,
    required  => 1,
    coerce    => 1,
);


has source  => (
    is        => 'ro',
    isa       => URI,
    key       => 'source',
    default   => 'http://cpan.perl.org',
    coerce    => 1,
    documentation => 'URL of a CPAN mirror (or Pinto repository) where foreign dists will be pulled from',
);


has nocleanup => (
    is        => 'ro',
    isa       => Bool,
    key       => 'nocleanup',
    default   => 0,
    documentation => 'If true, then Pinto will not delete older distributions when newer versions are added',
);


has noinit   => (
    is       => 'ro',
    isa      => Bool,
    key      => 'noinit',
    default  => 0,
    documentation => 'If true, then Pinto will not update/pull the repository from VCS before each action',
);


has store => (
    is        => 'ro',
    isa       => Str,
    key       => 'store',
    default   => 'Pinto::Store',
    documentation => 'Name of the class that will handle storage of your repository',
);


has svn_trunk => (
    is        => 'ro',
    isa       => Str,
    key       => 'trunk',
    section   => 'Pinto::Store::VCS::Svn',
);


has svn_tag => (
    is        => 'ro',
    isa       => Str,
    key       => 'tag',
    section   => 'Pinto::Store::VCS::Svn',
);

#------------------------------------------------------------------------------
# Builders

sub _build_config_file {
    my ($self) = @_;

    my $repos = $self->repos();

    my $config_file = Path::Class::file($repos, qw(config pinto.ini) );

    return -e $config_file ? $config_file : ();
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;

__END__

=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).

=cut
