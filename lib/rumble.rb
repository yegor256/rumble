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
require 'csv'
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
      if @opts[:test]
        emails = [['John', 'Doe', @opts[:test]]]
      else
        raise '--csv is required' unless @opts[:csv]
        emails = CSV.read(@opts[:csv])
      end
      total = 0
      sent = []
      ignore = !@opts[:resume].nil? && !@opts[:test]
      from = @opts[:from].strip
      puts "Sending #{emails.length} email(s) as #{from}"
      domain = from.strip.gsub(/^.+@|>$/)
      emails.each do |array|
        first = (array[@opts[:col0].to_i] || '').strip
        last = (array[@opts[:col1].to_i] || '').strip
        email = array[@opts[:col2].to_i]
        unless email
          puts Rainbow('Email is absent').red
          next
        end
        email = email.strip.downcase
        if sent.include?(email)
          puts Rainbow('duplicate').red
          next
        end
        sent.push(email)
        name = "#{first.strip} #{last.strip}".strip
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
          if @opts[:resume].downcase != email
            puts "ignored, waiting for #{@opts[:resume]}"
            next
          end
          ignore = false
        end
        if skip.include?(email)
          puts Rainbow('skipped').red
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
        total += 1
        puts "#{Rainbow('done').green} ##{total}"
      end
      puts "Processed #{sent.size} emails"
    end
  end
end
