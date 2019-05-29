<img src="/logo.svg" width="64px" height="64px"/>

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![Managed by Zerocracy](https://www.0crat.com/badge/C3RFVLU72.svg)](https://www.0crat.com/p/C3RFVLU72)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/rumble)](http://www.rultor.com/p/yegor256/rumble)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![Build Status](https://travis-ci.org/yegor256/rumble.svg)](https://travis-ci.org/yegor256/rumble)
[![Build status](https://ci.appveyor.com/api/projects/status/orvfo2qgmd1d7a2i?svg=true)](https://ci.appveyor.com/project/yegor256/rumble)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/rumble)](http://www.0pdd.com/p?name=yegor256/rumble)
[![Gem Version](https://badge.fury.io/rb/rumble.svg)](http://badge.fury.io/rb/rumble)
[![Maintainability](https://api.codeclimate.com/v1/badges/a3fee65d42a9cf6397ea/maintainability)](https://codeclimate.com/github/yegor256/rumble/maintainability)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/rumble.svg)](https://codecov.io/github/yegor256/rumble?branch=master)

[![Hits-of-Code](https://hitsofcode.com/github/yegor256/0rsk)](https://hitsofcode.com/view/github/yegor256/0rsk)

This command line tool helps you send newsletters.

Install it first:

```bash
$ gem install rumble
```

Run it locally and read its output:

```bash
$ rumble --help
```

Simple liquid letter looks like this:

```
{{ first }},

How are you?

Best,
Yegor
```

The list of emails must contain three columns separated by a comma: first
name, last name, and email.

If you want to send via HTTP/SMTP proxy, use `--proxy=socks:<host>:<port>`.

## How to contribute

Read [these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have [Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```
$ bundle update
$ bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.
