package Google::StreetView;

use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request;
use JSON;
use Log::Log4perl qw(:easy);
use Carp;

use strict;
use warnings FATAL => 'all';

# Override certificate check fail for now for dev - disable in production
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

sub new {

    my $class = shift;
    my $self = {};
    my %params = @_;

    # Values passed in by caller, typically loaded from conf/app.conf
    if (!defined $params{'api_key'})  {
        croak("Insufficient parameters: API key is required!");
    } else {
        if (length ($params{'api_key'}) < 20) {
            croak("Enter a valid Google Street View API key!")
        }
    }

    $self->{'_api_key'} = $params{'api_key'};

    if (!defined $params{'logger'})  {
        croak("Insufficient parameters: logger is required!");
    }

    $self->{'_logger'} = $params{'logger'};

    # Base StreetView API URL
    # See: https://developers.google.com/maps/documentation/streetview/metadata
    $self->{'_base_url'} = "https://maps.googleapis.com/maps/api/streetview/metadata";

    # Setup LWP
    $self->{'_browser'} = LWP::UserAgent->new();

    if ($params{'debug'} == 1) {
        $self->{'_browser'} ->add_handler( "request_send",  sub { shift->dump; return } );
        $self->{'_browser'} ->add_handler( "response_done", sub { shift->dump; return } );
    }

    bless $self, $class;

    $self;

}

sub convertLocationToPanoId {

    my $self = shift;
    my ($location) = @_;

    my $location_param;


    if ( (defined $location->{'latitude'}) &&
        (defined $location->{'longitude'}) ) {
        # Perform lookup by geocoordinates
        $location_param = $location->{'latitude'} . "," . $location->{'longitude'};
    } elsif (defined $location->{'location_text'}) {
        # Perform lookup by text - e.g. 'New York City'
        $location_param = $location->{'location_text'};
    } else {
        die("Either latitude/longitude or location_text is required!");
    }


    my $url = $self->{_base_url} . "?key=" . $self->{_api_key} . "&location=" . $location_param;

    $self->{_logger}->debug("Looking up location = " . Dumper($location) . "\n");

    my $request = new HTTP::Request "GET", $url;
    my $response = $self->{'_browser'}->request($request);

    if ( $response->code != 200 ) {

        $self->{_logger}->error("Got $response->code, exiting...");
        die "Invalid http status = " . Dumper($response->code) . "!";
    }

    my $json = from_json( $response->content );

    if ($json->{'status'} eq "ZERO_RESULTS") {
        warn "Received zero results for " . Dumper($location);
        return;
    }

    if ($json->{'status'} eq "REQUEST_DENIED") {
        warn "Received error [ $json->{'error_message'} ]";
        return;
    }

    my $pano_id = $json->{'pano_id'};

    return $pano_id;

}

sub convertPanoIdToLocation {

    my $self = shift;
    my ($pano_id) = @_;

    if (!defined $pano_id)  {
        die("pano_id is required!");
    }

    my $url = $self->{_base_url} . "?key=" . $self->{_api_key} . "&pano=" . $pano_id;

    $self->{_logger}->info("Looking up pano_id = " . $pano_id . "\n");

    my $request = new HTTP::Request "GET", $url;
    my $response = $self->{'_browser'}->request($request);

    if ( $response->code != 200 ) {

        $self->{_logger}->error("Got $response->code, exiting...");
        die "Invalid http status = " . Dumper($response->code) . "!";
    }

    my $json = from_json( $response->content );

    if ($json->{'status'} eq "ZERO_RESULTS") {
        warn "Received zero results for $pano_id";
        return;
    }

    if ($json->{'status'} eq "REQUEST_DENIED") {
        warn "Received error [ $json->{'error_message'} ]";
        return;
    }

    my $latitude = $json->{'location'}->{'lat'};

    if (length($latitude) <1) {
        die "Couldn't determine latitude from pano_id $pano_id";
    }

    my $longitude = $json->{'location'}->{'lng'};

    if (length($longitude) <1) {
        die "Couldn't determine longitude from pano_id $pano_id";
    }

    return {
        latitude  => $latitude,
        longitude => $longitude
    }

}


1;