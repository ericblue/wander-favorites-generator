#!/usr/bin/env perl

BEGIN { push( @INC, "./lib" ); }


use Mojolicious::Lite;
use Data::Dumper;
use Carp;
use Log::Log4perl qw(:easy);
use JSON;
use Mojo::IOLoop;
use Mojo::UserAgent;
# local  lib
use ConfigUtil;
use Google::StreetView;
use Wander::Favorites;

use strict;
use vars qw($logger $gsv);


## Mojolicious Controllers + REST endpoints

sub render_failure {

    my ($c, $message) = @_;

    my $response = {
        'status'  => "FAILURE",
        'message' => $message
    };

    # TODO set HTTP status to 500
    $c->render(json => $response);

}

# "real_ip" helper
helper real_ip => sub {
    my $self      = shift;
    my $forwarded = $self->req->headers->header('X-Forwarded-For');
    if ( defined($forwarded) ) {
        $forwarded =~ /([^,\s]+)$/ and return $1;
    }
    else {
        return $self->tx->{remote_address};
    }

};

# Handle generate favorties

post '/generate-favorites' => sub {

    my $c = shift;

    my $folder = $c->param('folder');
    my $locations_param = $c->req->body;


    #print "Got locations = $locations_param";

    my @locations = split(/\n/, $locations_param);

    my @favorite_locations = ();

    my $total_errors = 0;

    foreach my $line (@locations) {

        # Example:
        # New York City|My trip to New York
        # 35.671822206844446, 139.69669206926622|Yoyogi Park Tokyo, Japan
        my ($location_text, $title) = split(/\|/, $line);

        if (!defined($title)) {
            $title = $location_text;
        }

        my $l = {
            title         => $title,
            location_text => $location_text
        };

        my $pano_id;

        eval {
            $pano_id = $gsv->convertLocationToPanoId($l);
        };

        if ($@) {
            warn "Error converting location to panoid, reason =  $@";
        } else {

            if (!defined $pano_id)  {
                warn "No pano_id found, skipping...";
                $total_errors++;
                next;
            } else {

                print "Found pano = $pano_id\n";
                $l->{'pano_id'} = $pano_id;

                push(@favorite_locations, $l);
            }
        }


    }

    if (length($folder) < 1) {
        $folder = "myFolder";
    }

    my $favorites_json = Wander::Favorites::generate_favorites({
        favorite_locations => \@favorite_locations,
        folder             => $folder
    });

    my $success_response = {
        'status'            => "SUCCESS",
        'total_errors'      => $total_errors,
        'total_favorites'   => $#favorite_locations + 1,
        'favorites_json'    => $favorites_json
    };


    $c->render(json => $success_response);


};

# Return index
get '/' => sub {
    my $c = shift;
    $c->render( template => 'index' );

};

## Main

# Removes VAR1 on Dumper output
$Data::Dumper::Terse = 1;

# Initialize logger; you can override
Log::Log4perl->easy_init($INFO);
$logger = get_logger();


my $environment = $ENV{'ENVIRONMENT'};
$logger->info("Staring app with environment = " . $environment . "\n");
if ($environment eq "development") {
    $logger->info("Disabling caching for development...");
    *Mojo::Cache::get = sub { };
}

our $config_file = "conf/app.conf";
my $config = ConfigUtil::load_config($config_file);

our $gsv = Google::StreetView->new(
    api_key => $config->{'google_streetview_api_key'},
    logger  => $main::logger,
    debug   => 0
);


app->start;
