[![Build Status](https://travis-ci.org/OkinawaPM/SlackBot.svg?branch=master)](https://travis-ci.org/OkinawaPM/SlackBot)
# NAME

Okinawa::SlackBot - for Okinawa.pm slack

# USAGE
## 1. Setup `config.pl` in the `config` directory
```perl
+{
    name  => "perl", # bot name
    token => {
        key => "xoxb-289251..."
    }
};

```
## 2. Install modules and run

Case the [Carton](https://github.com/perl-carton/carton)

    carton install
    carton exec -- ./script/bot

Case the [Carmel](https://github.com/miyagawa/Carmel)

    carmel install
    carmel exec -- ./script/bot

## 3. Run tests
Case the [Carton](https://github.com/perl-carton/carton)

    carton exec -- prove

Case the [Carmel](https://github.com/miyagawa/Carmel)

    carmel exec -- prove

# LICENSE

Copyright (C) Code-Hex.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Code-Hex <x00.x7f@gmail.com>
