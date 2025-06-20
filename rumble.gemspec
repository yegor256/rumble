# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2018-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/rumble/version'
Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 3.0'
  s.name = 'rumble'
  s.version = Rumble::VERSION
  s.license = 'MIT'
  s.summary = 'Command Line Newsletter Sending Tool'
  s.description = 'Sends newsletters to recipients'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/yegor256/rumble'
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_dependency 'liquid', '5.5.0'
  s.add_dependency 'mail', '2.8.1'
  s.add_dependency 'net-smtp', '0.5.0'
  s.add_dependency 'net-smtp-proxy', '2.0.0'
  s.add_dependency 'openssl', '~>3.0'
  s.add_dependency 'rainbow', '3.1.1'
  s.add_dependency 'redcarpet', '3.6.0'
  s.add_dependency 'slop', '4.10.1'
  s.add_dependency 'uuidtools', '2.2.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
