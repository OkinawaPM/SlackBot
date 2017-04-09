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
requires 'String::Random';
requires 'Clone';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::MockObject::Extends'
};

