# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2018-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'test__helper'
require 'donce'
require 'fileutils'
require 'qbash'
require 'securerandom'
require 'tmpdir'

# Hermetic test that verifies bin/rumble runs in isolated Docker environment.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018-2026 Yegor Bugayenko
# License:: MIT
class TestHermetic < Minitest::Test
  def test_runs_in_docker_with_dry_mode
    skip('Docker is not available') unless docker?
    Dir.mktmpdir do |home|
      root = File.absolute_path(File.join(__dir__, '..'))
      FileUtils.cp(File.join(root, 'Gemfile'), home)
      FileUtils.cp(File.join(root, 'Gemfile.lock'), home)
      FileUtils.cp(File.join(root, 'rumble.gemspec'), home)
      FileUtils.cp_r(File.join(root, 'lib'), home)
      FileUtils.cp_r(File.join(root, 'bin'), home)
      File.write(File.join(home, 'letter.liquid'), "Test äöü #{SecureRandom.hex(8)}")
      File.write(
        File.join(home, 'Dockerfile'),
        [
          'FROM ruby:3.2',
          'WORKDIR /app',
          'COPY Gemfile Gemfile.lock rumble.gemspec /app/',
          'COPY lib /app/lib/',
          'COPY bin /app/bin/',
          'COPY letter.liquid /app/',
          'RUN bundle install --quiet'
        ].join("\n")
      )
      assert_includes(
        donce(
          home: home,
          args: '--network none',
          command: [
            'bin/rumble',
            '--dry',
            '--method=smtp',
            '--host=smpt.gmail.com',
            '--port=25',
            '--user=test',
            '--password=test',
            '--subject=test',
            '--test=test@example.com',
            '--from=test@example.com',
            '--letter=/app/letter.liquid'
          ],
          timeout: 300
        ),
        'done #1'
      )
    end
  end

  private

  def docker?
    qbash('docker --version', accept: nil).include?('Docker version')
  end
end
