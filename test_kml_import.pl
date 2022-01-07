#!/usr/bin/env perl

BEGIN { push( @INC, "./lib" ); }


use strict;
use warnings;
use Data::Dumper;
use XML::Twig;
use File::Slurp;
use Wander::KMLImporter;

eval {


    my $kml = read_file("t/best_friends.kml");
    my @locations = Wander::KMLImporter::convert_kml_data_to_locations($kml);

    print Dumper @locations;

};

if ($@) {
    warn "Error converting kml locations, reason =  $@";
}