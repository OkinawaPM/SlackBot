requires 'Time::Moment';
requires 'IO::Socket::SSL';
requires 'Mojolicious';
requires 'Reply';
requires 'Mouse';
requires 'Path::Tiny';
requires 'Data::Printer';
requires 'Mojo::SlackRTM';
requires 'BSD::Resource';
requires 'Mojo::IOLoop::ReadWriteFork';
requires 'Data::Util';
requires 'IO::String';
requires 'String::Random';
requires 'Storable';
requires 'Clone';
requires 'Attribute::Handlers';
requires 'Data::Structure::Util';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

