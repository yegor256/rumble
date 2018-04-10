# Copyright (c) 2018 Yegor Bugayenko
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

require 'mail'
require 'uuidtools'
require 'liquid'
require 'redcarpet'
require 'redcarpet/render_strip'
require 'rainbow'
require_relative 'rumble/version'

# Rumble main script.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018 Yegor Bugayenko
# License:: MIT
module Rumble
  # Command line interface.
  class CLI
    def initialize(opts)
      @opts = opts
    end

    def send
      letter = Liquid::Template.parse(
        File.read(File.expand_path(@opts[:letter]))
      )
      skip = @opts[:skip] ? File.readlines(@opts[:skip]).map(&:strip) : []
      emails = @opts[:test] ?
        ["John,Doe,#{@opts[:test]}"]
        : File.readlines(@opts[:targets]).map(&:strip).reject(&:empty?)
      total = 0
      sent = []
      ignore = !@opts[:resume].nil?
      from = @opts[:from].strip
      puts "Sending #{emails.length} email(s) as #{from}"
      domain = from.strip.gsub(/^.+@|>$/)
      emails.each do |line|
        first, last, email = line.split(',')
        email = email.strip.downcase
        name = "#{first} #{last}".strip
        address = email
        address = "#{name} <#{email}>" unless name.empty?
        print "Sending to #{address}... "
        markdown = letter.render(
          'email' => email, 'first' => first, 'last' => last
        )
        html = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
          .render(markdown)
        text = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
          .render(markdown)
        if ignore
          if opts[:resume] != email
            puts "ignored, waiting for #{opts[:resume]}"
            next
          end
          ignore = false
        end
        if skip.include?(email)
          puts Rainbow('skipped').red
          next
        end
        if sent.include?(email)
          puts Rainbow('duplicate').red
          next
        end
        subject = @opts[:subject]
        mail = Mail.new do
          from from
          to address
          subject subject
          message_id "<#{UUIDTools::UUID.random_create}@#{domain}>"
          text_part do
            content_type 'text/plain; charset=UTF-8'
            body text
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body html
          end
        end
        mail.deliver! unless @opts[:dry]
        sent.push(email)
        total += 1
        puts "#{Rainbow('done').green} ##{total}"
      end
      puts "Sent #{sent.size} emails"
    end
  end
end
