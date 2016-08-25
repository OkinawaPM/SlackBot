requires 'Time::Moment';
requires 'Scalar::Util';
requires 'IO::Socket::SSL';
requires 'Mojolicious';
requires 'Reply';
requires 'Mouse';
requires 'Path::Tiny';
requires 'Data::Printer';
requires 'Sys::SigAction';
requires 'Mojo::SlackRTM';
requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

