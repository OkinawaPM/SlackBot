#!perl
use Mojolicious::Lite;

use Proclet;
use File::Spec;
use Cwd 'getcwd';

use Mojo::Log;
use Mojo::UserAgent;

use Email::Valid;
use Mojo::Base 'Mojolicious::Controller';

my $log = Mojo::Log->new;
my $ua = Mojo::UserAgent->new;

get '/' => sub {
    my $c = shift;
    $c->render(template => 'index');
};

post '/invite' => sub {
    my $c = shift;

    my $email = Email::Valid->address($c->param('email'));
    unless ($email) {
        return $c->render(json => {
            result  => 'invalid email address',
            success => 0,
        });
    }

    my $tx = $ua->post(
        'https://okinawapm.slack.com/api/users.admin.invite' => {Accept => '*/*'}
        => form => {
           email      => $email,
           token      => $ENV{SLACK_TOKEN},
           set_active => 'true',
    });

    unless (my $res = $tx->success) {
        my $err = $tx->error;
        return $c->render(json => +{
            result  => $err,
            success => 0,
        });
    }

    $c->render(json => {
		result  => "Send invite message to $email",
        success => 1
	});
};

BEGIN { unshift @INC, File::Spec->catfile(getcwd, 'lib') }
require Okinawa::SlackBot;

my $proclet = Proclet->new;
my $slackbot = Okinawa::SlackBot->new(name => $ENV{BOT_NAME}, token => $ENV{SLACK_TOKEN});

my $pid = fork;
defined $pid or die 'Could not fork()';
unless ($pid) {
    $slackbot->run;
    exit;
}

$proclet->service(
    code   => sub {
        $log->info("Request to self: $ENV{URL}");
        my $tx = $ua->get($ENV{URL});
        $log->info("Status code: ".$tx->res->code);
    },
    worker => 1,
    every  => '*/15 0-16,23 * * *',
    tag    => 'Cron request',
);

$proclet->service(
    code   => sub {
        app->start('daemon', '-l', "http://*:$ENV{PORT}");
    },
    worker => 1,
    tag    => 'Invite form'
);

$proclet->run;

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
<head>
<title>Okinawa.pm slack invite page</title>
<meta charset="UTF-8">
<link rel="icon" href="/favicon.ico" type="image/x-icon">
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-1.10.2.js"></script>
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<style>
body {
    width: 100%;
    letter-spacing: .1em;
}
a {
	text-decoration:none;
}
a:visited {
	color: #ea6153;
}
pre {
	font-size: 14px;
	font-family: Monaco;
}
h1, h2 {
  color: #546E7A;
}
p {
	font-size:14px;
  color: #546E7A;
}
span {
	font-size:14px;
}
.success {
  color: #2ecc71;
}
.error {
  color: #c0392b;
}
</style>
<script>
$(function(){
  $('.submit').on('click', function(ev) {
    $('form input, button').prop('disabled', true);
    $.ajax({
      url: '/invite',
      success: function(data) {
        if (data.success == 1) {
          $('#message')
            .attr('class', 'success')
            .text(data.result);
        } else {
          $('#message')
            .attr('class', 'error')
            .text(data.result);
        }
        $('form input, button').prop('disabled', false);
      },
      data: { email: $('#email').val() },
      type: 'POST'
    });
    return false;
  });
});
</script>
<meta property="og:title" content="okinawapm" />
<meta property="og:type" content="website" />
<meta property="og:url" content="http://turtle.gq/slack_form" />
<meta property="og:site_name" content="Okinawa.pm slack invite page" />
<meta property="og:description" content="okinawapm.slack.comについての説明と自動登録フォーム" />
</head>
<body>
<div class="container">
  <div class="row">
    <div class="col-sm-8">
      <h1>Okinawa.pm Slack</h1>
    </div>
    <div class="col-sm-8">
      <p>沖縄県本島を中心とするPerl ユーザのコミュニティ形成を目指す非営利の団体です。 主な活動内容はプログラミング言語 Perl に関係するメンバー主催の勉強会やインターネット上での啓蒙活動や情報交換です。</p>
      <p>Okinawa.pm ってなんぞや!? という方は<a href="http://okinawa.pm.org/">Okinawa.pm blog</a>へアクセスしてみるといいかもしれません!!</p>
      <p>以下のフォームにメールアドレスを入れて「Invite Me」ボタンを押すと、アドレス宛てに Okinawa.pm の Slack への招待メールが届きます。</p>
    </div>
    <div class="col-sm-8">
      <h2>Okinawapm へ参加する</h2>
      <form class="form-horizontal" method="POST" action="/invite">
        <div class="form-group">
          <label for="email" class="col-sm-2 control-label">Email</label>
          <div class="col-sm-10">
            <input type="text" class="form-control" id="email" name="email" placeholder="Email" required />
          </div>
        </div>
        <div class="form-group">
          <div class="col-sm-offset-2 col-sm-10">
            <button type="button" class="submit btn btn-primary">Invite Me</button>
          </div>
        </div>
      </form>
      <div id="message"></div>
    </div>
    <div class="col-sm-8">
      <p>何か問題がありましたら <a href="https://twitter.com/CodeHex">@CodeHex</a> まで連絡ください！</p>
    </div>
  </div>
</div>
</body>
</html>
