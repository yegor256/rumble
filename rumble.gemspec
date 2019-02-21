# frozen_string_literal: true

# Copyright (c) 2018-2019 Yegor Bugayenko
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/rumble/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version = Gem::Requirement.new('>= 0')
  end
  s.rubygems_version = '2.2'
  s.required_ruby_version = '>= 2.3'
  s.name = 'rumble'
  s.version = Rumble::VERSION
  s.license = 'MIT'
  s.summary = 'Command Line Newsletter Sending Tool'
  s.description = 'Sends newsletters to recipients'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'http://github.com/yegor256/rumble'
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_runtime_dependency 'liquid', '4.0.1'
  s.add_runtime_dependency 'mail', '2.7.1'
  s.add_runtime_dependency 'rainbow', '3.0.0'
  s.add_runtime_dependency 'redcarpet', '3.4.0'
  s.add_runtime_dependency 'slop', '4.6.2'
  s.add_runtime_dependency 'uuidtools', '2.1.5'
  s.add_development_dependency 'codecov', '0.1.10'
  s.add_development_dependency 'cucumber', '1.3.17'
  s.add_development_dependency 'minitest', '5.5.0'
  s.add_development_dependency 'rake', '12.0.0'
  s.add_development_dependency 'rdoc', '4.2.0'
  s.add_development_dependency 'rspec-rails', '3.1.0'
  s.add_development_dependency 'rubocop', '0.61.0'
  s.add_development_dependency 'rubocop-rspec', '1.31.0'
end
