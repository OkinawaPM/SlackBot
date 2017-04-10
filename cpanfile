requires 'Mouse';
requires 'Clone';
requires 'Proclet';
requires 'Mojolicious';
requires 'IO::Socket::SSL';
requires 'Data::Printer';
requires 'Mojo::SlackRTM';
requires 'BSD::Resource';
requires 'String::Random';
requires 'Module::Load';
requires 'Email::Valid';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::MockObject::Extends'
};

