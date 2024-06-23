# Command Line Mass-Email Sender

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/rumble)](http://www.rultor.com/p/yegor256/rumble)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/rumble/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/rumble/actions/workflows/rake.yml)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/rumble)](http://www.0pdd.com/p?name=yegor256/rumble)
[![Gem Version](https://badge.fury.io/rb/rumble.svg)](http://badge.fury.io/rb/rumble)
[![Maintainability](https://api.codeclimate.com/v1/badges/a3fee65d42a9cf6397ea/maintainability)](https://codeclimate.com/github/yegor256/rumble/maintainability)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/rumble.svg)](https://codecov.io/github/yegor256/rumble?branch=master)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/0rsk)](https://hitsofcode.com/view/github/yegor256/0rsk)

This command line tool helps you send newsletters.

Install it first:

```bash
gem install rumble
```

Run it locally and read its output:

```bash
rumble --help
```

Simple liquid letter looks like this:

```liquid
{{ first }},

How are you?

Best,
Yegor
```

The list of emails must contain three columns separated by a comma: first
name, last name, and email.

You can't send via HTTP/SMTP proxy, unfortunately (you are welcome
to submit a pull request).

## How to contribute

Read
[these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have
[Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```bash
bundle update
bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.
