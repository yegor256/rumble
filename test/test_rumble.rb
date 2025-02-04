# frozen_string_literal: true

# Copyright (c) 2018-2025 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require 'tmpdir'
require 'slop'
require 'random-port'
require 'shellwords'
require 'qbash'
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

  def test_with_mailhog
    Dir.mktmpdir do |home|
      flag = File.join(home, 'sent.txt')
      letter = File.join(home, 'letter.liquid')
      File.write(letter, 'Hi!')
      host = 'localhost'
      RandomPort::Pool::SINGLETON.acquire(2) do |smtp, http|
        daemon("docker run --rm -p #{smtp}:1025 -p #{http}:8025 mailhog/mailhog", flag)
        wait_for(host, http)
        qbash(
          [
            Shellwords.escape(File.join(__dir__, '../bin/rumble')),
            '--port', smtp,
            '--host', host,
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
    skip('This baby does not work :(')
    Dir.mktmpdir do |home|
      flag = File.join(home, 'sent.txt')
      letter = File.join(home, 'letter.liquid')
      File.write(letter, 'Hi!')
      host = 'localhost'
      certs = File.join(home, 'certs')
      FileUtils.mkdir_p(certs)
      qbash("openssl genrsa -out #{Shellwords.escape(File.join(certs, 'key.pem'))} 2048")
      qbash(
        [
          'openssl req -x509 -new -nodes',
          "-key #{Shellwords.escape(File.join(certs, 'key.pem'))}",
          '-sha256 -days 1024',
          "-out #{Shellwords.escape(File.join(certs, 'cert.pem'))}",
          '-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"'
        ]
      )
      RandomPort::Pool::SINGLETON.acquire(2) do |smtp, http|
        daemon(
          [
            'docker run --rm',
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
            '--port', smtp,
            '--host', host,
            '--tls',
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

  def wait_for(host, port)
    loop do
      TCPSocket.new(host, port).close
      break
    rescue Errno::ECONNREFUSED => e
      sleep(1)
      puts "Waiting for mailhog at #{host}:#{port}: #{e.message}"
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
