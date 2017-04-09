requires 'Time::Moment';
requires 'IO::Socket::SSL';
requires 'Mojolicious';
requires 'Mouse';
requires 'Data::Printer';
requires 'Mojo::SlackRTM';
requires 'BSD::Resource';
requires 'String::Random';
requires 'Module::Load';
requires 'Clone';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::MockObject::Extends'
};

