# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2018-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require 'os'
require 'qbash'
require 'random-port'
require 'shellwords'
require 'slop'
require 'tmpdir'
require_relative '../lib/rumble'
require_relative '../lib/rumble/cli'

# Rumble main module test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018-2025 Yegor Bugayenko
# License:: MIT
class TestRumble < Minitest::Test
  def test_basic
    Dir.mktmpdir do |dir|
      letter = File.join(dir, 'letter.liquid')
      File.write(letter, 'Hi {{first}}, how are you?')
      Rumble::CLI.new(
        dry: true,
        test: 'test@yegor256.com',
        letter: letter,
        host: 'localhost',
        from: 'Yegor Bugayenko <yegor256@gmail.com>'
      ).send
    end
  end

  def test_with_live_gmail
    skip('This is live test')
    cfg = File.absolute_path(File.join(Dir.home, '.rumble'))
    skip('No ~/.rumble file available') unless File.exist?(cfg)
    Dir.mktmpdir do |home|
      letter = File.join(home, 'letter.liquid')
      File.write(letter, 'it is a test, please delete it')
      qbash(
        [
          Shellwords.escape(File.join(__dir__, '../bin/rumble')),
          '--method=smtp',
          '--subject', 'rumble test email',
          '--test', 'rumble+test@yegor256.com',
          '--tls',
          '--from', Shellwords.escape('Tester <yegor@zerocracy.com>'),
          '--letter', Shellwords.escape(letter)
        ]
      )
    end
  end

  def test_with_mailhog
    skip('Works only on Ubuntu') if OS.mac? || OS.windows?
    Dir.mktmpdir do |home|
      flag = File.join(home, 'sent.txt')
      letter = File.join(home, 'letter.liquid')
      File.write(letter, 'Hi!')
      host = 'localhost'
      RandomPort::Pool::SINGLETON.acquire(2) do |smtp, http|
        daemon("#{docker} run --rm -p #{smtp}:1025 -p #{http}:8025 mailhog/mailhog", flag)
        wait_for(host, http)
        qbash(
          [
            Shellwords.escape(File.join(__dir__, '../bin/rumble')),
            '--method=smtp',
            '--port', smtp,
            '--host', host,
            '--user=foo', '--password=foo',
            '--subject', 'testing',
            '--test', 'to@example.com',
            '--from', Shellwords.escape('tester <from@example.com>'),
            '--letter', Shellwords.escape(letter)
          ]
        )
        FileUtils.touch(flag)
      end
    end
  end

  def test_with_mailhog_with_tls
    skip('Works only on Ubuntu') if OS.mac? || OS.windows?
    Dir.mktmpdir do |home|
      flag = File.join(home, 'sent.txt')
      letter = File.join(home, 'letter.liquid')
      File.write(letter, 'Hi!')
      host = 'localhost'
      certs = File.join(home, 'certs')
      FileUtils.mkdir_p(certs)
      qbash("openssl genrsa -out #{Shellwords.escape(File.join(certs, 'key.pem'))} 2048", log: $stdout)
      qbash(
        [
          'openssl req -x509 -new -nodes',
          "-key #{Shellwords.escape(File.join(certs, 'key.pem'))}",
          '-sha256 -days 1024',
          "-out #{Shellwords.escape(File.join(certs, 'cert.pem'))}",
          '-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"'
        ],
        log: $stdout
      )
      RandomPort::Pool::SINGLETON.acquire(2) do |smtp, http|
        daemon(
          [
            "#{docker} run --rm",
            "-p #{smtp}:1025",
            "-p #{http}:8025",
            "-v #{Shellwords.escape(certs)}:/etc/certs",
            '-e MH_TLS_BIND_ADDR=:1025',
            '-e MH_STORAGE=maildir',
            '-e MH_MAILDIR_PATH=/tmp/mailhog',
            '-e MH_TLS_CERT_FILE=/etc/certs/cert.pem',
            '-e MH_TLS_PRIV_KEY=/etc/certs/key.pem',
            'mailhog/mailhog'
          ],
          flag
        )
        wait_for(host, http)
        qbash(
          [
            Shellwords.escape(File.join(__dir__, '../bin/rumble')),
            '--method=smtp',
            '--port', smtp,
            '--host', host,
            '--tls',
            '--user=foo', '--password=foo',
            '--subject', 'testing',
            '--test', 'to@example.com',
            '--from', Shellwords.escape('tester <from@example.com>'),
            '--letter', Shellwords.escape(letter)
          ]
        )
        FileUtils.touch(flag)
      end
    end
  end

  private

  def docker
    if ENV['DOCKER_SUDO'] == 'true'
      'sudo docker'
    else
      'docker'
    end
  end

  def wait_for(host, port)
    start = Time.now
    loop do
      TCPSocket.new(host, port).close
      break
    rescue Errno::ECONNREFUSED => e
      sleep(1)
      puts "Waiting for mailhog at #{host}:#{port}: #{e.message}"
      raise e if Time.now - start > 120
      retry
    end
  end

  def daemon(cmd, flag)
    Thread.new do
      qbash(cmd, log: $stdout) do |pid|
        loop do
          break if File.exist?(flag)
        end
        Process.kill('KILL', pid)
      end
    end
  end
end
