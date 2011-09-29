package Pinto::Action::Purge;

# ABSTRACT: Remove all distributions from the repository

use Moose;

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

extends 'Pinto::Action';

#------------------------------------------------------------------------------

override execute => sub {
    my ($self) = @_;

    my $dists = $self->db->get_all_distributions();

    my $removed = 0;
    while ( my $dist = $dists->next() ) {
        my $file = $dist->physical_path( $self->config->repos() );
        $self->db->remove_distribution($dist);
        $self->store->remove_archive( $file );
        $removed++
    }

    $self->add_message("Purged all $removed distributions" ) if $removed;

    return $removed;
};

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;

__END__
