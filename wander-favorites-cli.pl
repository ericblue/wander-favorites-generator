#!/usr/bin/env perl

BEGIN { push( @INC, "./lib" ); }

use Data::Dumper;
use Carp;
use Log::Log4perl qw(:easy);

# local  lib
use ConfigUtil;
use Google::StreetView;
use Wander::Favorites;

use strict;
use vars qw($logger);



## Main

# Removes VAR1 on Dumper output
$Data::Dumper::Terse = 1;

# Initialize logger; you can override
Log::Log4perl->easy_init($INFO);
$logger = get_logger();

our $config_file = "conf/app.conf";
my $config = ConfigUtil::load_config($config_file);

my $gsv = Google::StreetView->new(
    api_key => $config->{'google_streetview_api_key'},
    logger  => $main::logger,
    debug   => 1
);

my @locations = (

    {
        title     => "Yoyogi Park, 2 Yoyogikamizonocho, Shibuya City, Tokyo, Japan",
        latitude  => 35.671822206844446,
        longitude => 139.69669206926622
    },
    {
        title     => "Stanford University",
        latitude  => 37.4280403,
        longitude => -122.1668571
    },
    {
        title         => "New York City",
        description   => "Detailed description for personal notes - not read by Wander currently",
        location_text => "New York City"
    },
    {
        title         => "New York City 2",
        description   => "Test passing in coordinates as text",
        location_text => "40.7530751,-73.9955315"
    }

);

# Favorite locations that have a panoid
my @favorite_locations = ();

foreach my $location (@locations) {


    print "Looking up location for " . Dumper($location) . "\n";

    my $pano_id;

    eval {
        $pano_id = $gsv->convertLocationToPanoId($location);
    };

    if ($@) {
        warn "Error converting location to panoid, reason =  $@";
    } else {

        if (!defined $pano_id)  {
            warn "No pano_id found, skipping...";
            next;
        } else {

            print "Found pano = $pano_id\n";
            $location->{'pano_id'} = $pano_id;

            push(@favorite_locations, $location);
        }
    }

}

my $favorites_json = Wander::Favorites::generate_favorites({
    favorite_locations => \@favorite_locations,
    folder             => 'MyFolder'
});

my $filename = '/Users/ericblue/Downloads/Wander_Favorites.json';

$logger->info("Saving favorites JSON to $filename\n");

open(FAVORITES,">$filename") or croak "Can't open favorites $filename";
print FAVORITES $favorites_json;
close(FAVORITES);

