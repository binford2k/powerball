# powerball
## The stupid simple Slack lotto bot.

This is a stupid simple Slack bot that just draws a winner each hour from
a CSV specified list. It's single purpose in design, so it's quite unlikely
to be of any use to you.

### Configuration

`powerball` reads its configuration from `config.yaml` in the current directory. The
format looks something like this:

``` Yaml
---
:admins:
  - binford2k
  - meg
  - anna
:channel: apitesting
:token: "<my slack api token>"
:starting: "2017-12-07 13:00 UTC"
```

The attendee input comes (by default) from `attendees.csv` in the current directory. Its
format is that of an attendee report dumped from EventBrite. The fields we care about can
be seen in the [source code](https://github.com/binford2k/powerball/blob/master/lib/powerball/lottery.rb).

### Usage

All the options from `config.yaml` can also be specified on the command line. Use the `--help`
flag for usage.

```
$ powerball --help

Usage : powerball [-t <token>] [-c <channel>] [-a <admins>] [--starting '2017-12-07 13:00 UTC']

         -- Starts the Powerball lotto bot.
    -t, --token TOKEN                Slack token.
    -c, --channel CHANNEL            Slack channel.
    -a, --admins ADMINS              Comma separated list of admin Slack usernames
        --attendees PATH             Path to CSV file from EventBrite containing attendees.
        --winners PATH               Path to CSV file to save the winners in.
        --starting TIME              Time to start the drawing.

    -h, --help                       Displays this help
```

## Limitations

This is super early in development and has not yet been battle tested. It might eat your kitten.

## Disclaimer

I take no liability for the use of this tool.

Contact
-------

binford2k@gmail.com
