# ABSTRACT: Specifies a package by name and version

package Pinto::PackageSpec;

use Moose;
use MooseX::MarkAsMethods ( autoclean => 1 );
use MooseX::Types::Moose qw(Str);

use Module::CoreList;
use CPAN::Meta::Requirements;

use Pinto::Util qw(throw trim_text);

use version;
use overload ( '""' => 'to_string', '>=' => 'gte');

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

has name => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has version => (
    is      => 'ro',
    isa     => Str,
    default => '0',
);

#------------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my @args = @_;
    my ($name, $version);

    if ( @args == 1 and not ref $args[0] ) {
        my ( $name, $version ) = $_[0] =~ m{^ ([A-Z0-9_:]+) (?:~)? (.*)}ix;
        $version =~ s/^\@/==/; # Allow "@" as a synonym for "=="
        @args = ( name => $name, version => trim_text($version) || 0 );
    }

    return $class->$orig(@args);
};

#------------------------------------------------------------------------------

=method is_core

=method is_core(in => $version)

Returns true if this package is satisfied by the perl core as-of a particular
version.  If the version is not specified, it defaults to whatever version
you are using now.

=cut

sub is_core {
    my ( $self, %args ) = @_;

    ## no critic qw(PackageVar);

    # Note: $PERL_VERSION is broken on old perls, so we must make
    # our own version object from the old $] variable

    my $pv = version->parse( $args{in} ) || version->parse($]);
    my $core_modules = $Module::CoreList::version{ $pv->numify + 0 };

    throw "Invalid perl version $pv" if not $core_modules;

    return 0 if not exists $core_modules->{ $self->name };

    # on some perls, we'll get an 'uninitialized' warning when
    # the $core_version is undef.  So force to zero in that case
    my $core_version = $core_modules->{ $self->name } || 0;

    return 1 if $self->is_satisfied_by( $core_version );
    return 0;
}

#-------------------------------------------------------------------------------

=method is_perl()

Returns true if this package is perl itself.

=cut

sub is_perl {
    my ($self) = @_;

    return $self->name eq 'perl' ? 1 : 0;
}

#-------------------------------------------------------------------------------

=method is_satisfied_by($version)

Returns true if this prerequisite is satisfied by version C<$version> of the package

=cut

sub is_satisfied_by {
    my ($self, $version) = @_;

    my $req = eval {
        my $args = {$self->name => $self->version};
        CPAN::Meta::Requirements->from_string_hash($args);
    };

    throw "Invalid prerequisite spec ($self): $@" if $@;
    return 1 if $req->accepts_module($self->name => $version);
    return 0;
}

#-------------------------------------------------------------------------------

=method to_string()

Serializes this PackageSpec to its string form.  This method is called
whenever the PackageSpec is evaluated in string context.

=cut

sub to_string {
    my ($self) = @_;
    my $format = $self->version =~ m/^ [=<>!\@] /x ? '%s%s' : '%s~%s';
    return sprintf $format, $self->name, $self->version;
}

#------------------------------------------------------------------------------

sub gte {
    my ($self, $other, $flip) = @_;
    return $self->is_satisfied_by($other) if not $flip;
    return $other->is_satisfied_By($self) if $flip;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

