#!/usr/bin/env perl

package ConfigUtil;
require Exporter;

use strict;
use warnings FATAL => 'all';
use Carp;
use Data::Dumper;
use Log::Log4perl qw(:easy);

our @ISA = qw(Exporter);
our @EXPORT =
    qw(load_config save_config);

# Initialize logger; you can overide
Log::Log4perl->easy_init($INFO);
my $logger = get_logger();

# Reads config file from app.conf
# Example:
#{
#    # Enable/disable debug logging
#    'debug' => 0,
#    # Google Streetview API key to convert to/from geo coordinates and panoid values
#     'google_streetview_api_key' => 'YOUR_API_KEY',
#}

sub load_config {

    my ($filename) = @_;

    $logger->info("Reading config file $filename");

    $/ = "";

    open( CONFIG, "$filename" ) or croak "Can't open config $filename!";
    my $config_file = <CONFIG>;
    close(CONFIG);
    undef $/;

    my $config = eval($config_file) or croak "Invalid config file format!";

    $logger->info("Config = " . Dumper($config));

    return $config;


}

# Saves updated config file (data contained in $config var) to $config_file

sub save_config {

    my ($config,$filename) = @_;

    $logger->info("Saving config file ");

    my $config_output = Dumper($config);

    open(CONFIG,">$filename") or croak "Can't open config $filename";
    print CONFIG $config_output;
    close(CONFIG);

}


1;