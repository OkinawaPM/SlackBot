use Test::More;

use File::Spec;
use Cwd 'getcwd';
BEGIN { unshift @INC, File::Spec->catfile(getcwd, "lib") }
use Okinawa::Base -default;

package Okinawa::BaseTest {
    use Okinawa::Base -base;

    has hoge => (
        is       => 'ro',
        isa      => 'Int',
        required => 1
    );

    has fuga => (
        is      => 'ro',
        default => sub { 'Nice Body' }
    );
};

my $obj = Okinawa::BaseTest->new(hoge => 2017);
is $obj->hoge, 2017, 'right attribute value (Mouse import)';
is $obj->fuga, 'Nice Body', 'right attribute value (Mouse import)';

is classpath('Okinawa::Base'), File::Spec->catfile(getcwd, 'lib', 'Okinawa', 'Base'), 'classpath test';

done_testing;