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
requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

