use Mojo::Base -strict;

use Test::More;
use Mojo::Message::Response;
use Mojo::Server::CGI::LegacyMigrate;
use Mojolicious::Command::cgi;
use Mojolicious::Lite;

# Silence
app->log->level('fatal');

get '/' => {text => 'Your Mojo is working!'};


# Simple
my $msg = '';
{
  local *STDOUT;
  open STDOUT, '>', \$msg;
  local %ENV = (
    PATH_INFO       => '/',
    REQUEST_METHOD  => 'GET',
    SCRIPT_NAME     => '/',
    HTTP_HOST       => 'localhost:8080',
    SERVER_PROTOCOL => 'HTTP/1.0'
  );
	print STDOUT "FAKE HTTP HEADER 200 OK\x0d\x0a";
  is(Mojolicious::Command::cgi->new(app => app)->run, 200, 'right status');
}

my $res = Mojo::Message::Response->new->parse("HTTP/1.1 200 OK\x0d\x0a$msg");
is $res->code, 200, undef;
is $res->headers->status, undef, 'right "Status" value';
is $res->headers->content_length, undef,       'right "Content-Length" value';
is $res->headers->content_type, undef, 'right "Content-Type" value';
ok defined $res->body, "totally undefined body, you're on your own.";

done_testing();
