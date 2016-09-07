package Okinawa::SlackBot::Plugin;

use Okinawa::Base -base;
extends 'Okinawa::SlackBot';

sub load {
	my $self = shift;
	my $path = classpath(__PACKAGE__);

	# package list under "Plugin" directory
	opendir(DH, $path) or die "Could not opendir: $!";
	my @pm = grep { $_ !~ /^\.+$/ } readdir(DH);
	closedir(DH);

	# load plugins
	eval {
		for my $plugin (@pm) {
			require "$path/$plugin";
			$plugin =~ s/\.pm$//;
			my $method = lc $plugin;
			my $package = __PACKAGE__."::$plugin";
			$self->log->info("Load method: $package->$method");

			# About "sub { $package->$method(pop @_) }"
			# @_ == ([0] => $class, [1] => $argument)
			# So remove first element "Okinawa::SlackBot::Plugin" class
			$self->meta->add_method($method => sub { $package->$method(pop @_) });
		}
	};
	if ($@) {
		$self->log->warn($@);
	}
	return $self;
}

__PACKAGE__->meta->make_immutable();

1;