package Wander::KMLImporter;

use Data::Dumper;
use XML::Twig;
use strict;
use warnings FATAL => 'all';


sub convert_kml_data_to_locations {

    my ($kml) = @_;

    # See: https://stackoverflow.com/questions/17231031/how-to-parse-kml-files-using-perl
    # Of the many options, XML::Twig is fairly lightweight for this

    # Sample KML data and elements we're searching for

    # <Placemark>
    #     <name>Seaport Village</name>
    #       <styleUrl>#icon-22-nodesc</styleUrl>
    #         <Point>
    #     <coordinates>
    #         -117.170079,32.709173,0
    #     </coordinates>
    #     </Point>
    # </Placemark>


    # Save latitude, longitude and placemark name on the list
    my @locations = ();

    XML::Twig->new( twig_roots => {
        Placemark => sub {
            my $name =  $_->first_child('name')->text;

            my $latitude;
            my $longitude;

            my $xml_coords = $_->first_child('Point')->first_child('coordinates');
            if (defined ($xml_coords)) {
                my $coordinates = $xml_coords->text;
                # strip extra, and unexplained whitespace and newlines
                $coordinates =~ s/[\r\n]+//g;
                $coordinates =~ s/^\s+|\s+$//g;
                ($longitude, $latitude, my $n) = split(/,/, $coordinates);
            }

            #print "$latitude,$longitude|$name\n";

            my $location = {
                latitude  => $latitude,
                longitude => $longitude,
                name      => $name
            };

            push(@locations, $location);

        }
    })
        ->safe_parse("$kml");

    return @locations;

}

1;