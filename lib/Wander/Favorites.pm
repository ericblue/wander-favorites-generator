#!/usr/bin/env perl

package Wander::Favorites;
require Exporter;

use strict;
use warnings FATAL => 'all';
use Carp;
use Data::Dumper;
use JSON;
use Log::Log4perl qw(:easy);

our @ISA = qw(Exporter);
our @EXPORT =
    qw(generate_favorites);

# Initialize logger; you can overide
Log::Log4perl->easy_init($INFO);
my $logger = get_logger();


# Saves updated config file (data contained in $config var) to $config_file

sub generate_favorites {

    my ($params) = @_;


    if (!defined $params->{'favorite_locations'})  {
        croak("Insufficient parameters: favorite_locations is required!");
    }

    if (!defined $params->{'folder'})  {
        croak("Insufficient parameters: folder is required!");
    }

    my @favorite_locations = @{$params->{'favorite_locations'}};
    my $total_locations = $#favorite_locations + 1;

    $logger->info("Generating favorites for " . $total_locations . " locations");

    #print Dumper $params->{'favorite_locations'};

    my @folder_contents;

    # Taking a cue from jedit.py at https://sourceforge.net/projects/wander-vr-utilities/files/editor/
    # Faking timestamps;  Wander seems to use to order places rather than the order of the list
    # TODO Investigate this further - hack for now

    my $timestamp = time * 100000000;

    foreach (@favorite_locations) {

        my $loc = {
            isFolder    => \0,
            title       => $_->{'title'},
            panoid      => $_->{'pano_id'},
            timeStamp   => $timestamp
        };

        # Add an optional description attribute if it's supplied
        if (defined($_->{'description'})) {
            $loc->{'description'} = $_->{'description'},
        }

        push(@folder_contents, $loc);

        $timestamp -= 1000;

    }


    my $json_favorites = {

        isFolder        => \1,
        title           => $params->{'folder'},
        folderContents => \@folder_contents,
        timeStamp       => time * 100000000,


    };

    my @json_output = ($json_favorites);

    my $json = JSON->new->pretty->encode(\@json_output);

    return $json;

}


1;