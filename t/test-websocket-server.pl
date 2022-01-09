#!/usr/bin/env perl

# Source: http://mojolicious.org/perldoc/Mojolicious/Guides/Tutorial#WebSockets
use Mojolicious::Lite;
use Mojo::IOLoop;
use Log::Log4perl qw(:easy);


use vars qw($logger);


websocket '/echo' => sub {
    my $c = shift;

    # Increase inactivity timeout for connection
    $c->inactivity_timeout(300);

    $c->on(json => sub {
        my ($c, $hash) = @_;
        $hash->{msg} = "echo: $hash->{msg}";
        $c->send({json => $hash});
    });
};


sub stop_polling {

    my ($c, $polling_id) = @_;

    $logger->info("Stopping current poll loop for pid $polling_id");

    $c->session('polling_id' => undef);
    $c->session('is_polling' => undef);
    Mojo::IOLoop->remove($polling_id);

}

sub poll_import_status {

    my ($c, $interval) = @_;

    $| = 1;

    # Creates a time for $interval duration, poll status of location import status

    my $max_polls = 3;
    my $polls = 0;

    $c->session('is_polling' => 1);

    $c->session('polling_id' => Mojo::IOLoop->recurring(5 => sub ($ioloop) {

        $logger->debug("ok, polling_id = $c->session->{polling_id}, interval = $interval\n");

        if ($polls >= $max_polls) {

            stop_polling($c, $c->session('polling_id'));

        } else {

            $logger->info("ok $polls  " . $c->session('polling_id'));
            $polls++;

        }


    }));


}

post '/test/' => sub {

    my $c = shift;

    #print Dumper $c->session;

    if (defined($c->session('is_polling'))) {
        $logger->info("Found polling id = " . $c->session('polling_id'));
        stop_polling($c, $c->session('polling_id'));
    }

    poll_import_status($c, 4);


    my $success_response = {
        'status'            => "SUCCESS",
    };


    $c->render(json => $success_response);



};

get '/' => 'index';


$Data::Dumper::Terse = 1;

# Initialize logger; you can override
Log::Log4perl->easy_init($INFO);
$logger = get_logger();

app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>Echo</title>
    <script>
      var ws = new WebSocket('<%= url_for('echo')->to_abs %>');
      ws.onmessage = function (event) {
        document.body.innerHTML += JSON.parse(event.data).msg;
      };
      ws.onopen = function (event) {
        ws.send(JSON.stringify({msg: 'I ♥ Mojolicious!'}));
      };
    </script>
  </head>
</html>