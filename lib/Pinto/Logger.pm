package Pinto::Logger;

# ABSTRACT: A simple logger

use Moose;

use MooseX::Types::Moose qw(Int Bool);
use Pinto::Types  0.017 qw(IO);

use Readonly;
use Term::ANSIColor 2.02;

use namespace::autoclean;

#-----------------------------------------------------------------------------

# VERSION

#-----------------------------------------------------------------------------
# Moose attributes

has verbose  => (
    is       => 'ro',
    isa      => Int,
    default  => 0,
);

has out => (
    is       => 'ro',
    isa      => IO,
    coerce   => 1,
    default  => sub { [fileno(STDOUT), '>'] },
);

has nocolor => (
    is       => 'ro',
    isa      => Bool,
    default  => 0,
);

#-----------------------------------------------------------------------------

Readonly my $LEVEL_QUIET => -2;
Readonly my $LEVEL_WARN  => -1;
Readonly my $LEVEL_INFO  =>  0;
Readonly my $LEVEL_DEBUG =>  1;

#-----------------------------------------------------------------------------

sub BUILDARGS {
    my ($class, %args) = @_;

    $args{verbose} = $LEVEL_QUIET if delete $args{quiet};

    return \%args;
}

#-----------------------------------------------------------------------------
# Private methods

sub _logit {
    my ($self, $message) = @_;

    return print { $self->out() } "$message\n";
}

#-----------------------------------------------------------------------------
# Public methods

=method debug( $message )

Logs a message if C<verbose> is 1 or higher.

=cut

sub debug {
    my ($self, $message) = @_;

    chomp $message;
    $self->_logit($message) if $self->verbose() >= $LEVEL_DEBUG;

    return 1;
}

#-----------------------------------------------------------------------------

=method info( $message )

Logs a message if C<verbose> is 0 or higher.

=cut

sub info {
    my ($self, $message) = @_;

    chomp $message;
    $self->_logit($message) if $self->verbose() >= $LEVEL_INFO;

    return 1;
}

#-----------------------------------------------------------------------------

=method whine( $message )

Logs a message to C<verbose> is -1 or higher.

=cut

sub whine {
    my ($self, $message) = @_;

    chomp $message;
    $message = _colorize($message, 'bold yellow') unless $self->nocolor();
    $self->_logit($message) if $self->verbose() >= $LEVEL_WARN;

    return 1;
}

#-----------------------------------------------------------------------------

=method fatal( $message )

Dies with the given message.

=cut

sub fatal {
    my ($self, $message) = @_;

    chomp $message;
    $message = _colorize($message, 'bold red') unless $self->nocolor();

    die "$message\n";                     ## no critic (RequireCarping)
}

#-----------------------------------------------------------------------------

sub _colorize {
    my ($string, $color) = @_;

    return $string if not defined $color;
    return $string if $color eq q{};

    # TODO: Don't colorize if not going to a terminal?

    # $terminator is a purely cosmetic change to make the color end at the end
    # of the line rather than right before the next line. It is here because
    # if you use background colors, some console windows display a little
    # fragment of colored background before the next uncolored (or
    # differently-colored) line.

    my $terminator = chomp $string ? "\n" : q{};
    return  Term::ANSIColor::colored( $string, $color ) . $terminator;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;

__END__
