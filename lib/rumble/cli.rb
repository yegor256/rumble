# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2018-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'csv'
require 'English'
require 'liquid'
require 'mail'
require 'rainbow'
require 'redcarpet'
require 'redcarpet/render_strip'
require 'tmpdir'
require 'uuidtools'
require_relative 'version'

# Rumble main script.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018-2025 Yegor Bugayenko
# License:: MIT
class Rumble::CLI
  # Make an instance.
  def initialize(opts)
    @opts = opts
  end

  # Send a letter, reading options from the opts.
  def send
    letter = Liquid::Template.parse(
      File.read(File.expand_path(@opts[:letter]))
    )
    skip = @opts[:skip] ? File.readlines(@opts[:skip]).map(&:strip) : []
    if @opts[:test]
      rcpt = []
      rcpt[@opts['col-first'].to_i] = 'John'
      rcpt[@opts['col-last'].to_i] = 'Doe'
      rcpt[@opts['col-email'].to_i] = @opts[:test]
      emails = [rcpt]
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
      email = array[@opts['col-email'].to_i]
      unless email
        puts \
          "Email is #{Rainbow('absent').red} " \
          "at the column ##{@opts['col-email'].to_i}: #{array}"
        next
      end
      email = email.strip.downcase
      if sent.include?(email)
        puts "#{Rainbow('Duplicate').red} at: #{array}"
        next
      end
      sent.push(email)
      first = (array[@opts['col-first'].to_i] || '').strip
      last = (array[@opts['col-last'].to_i] || '').strip
      first, last = first.split(' ', 2) if last.empty? && first.include?(' ')
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
          puts "#{Rainbow('ignored').orange}, waiting for #{@opts[:resume]}"
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
      if @opts[:attach]
        Dir.mktmpdir do |dir|
          `#{@opts[:attach]} "#{email}" "#{name}" "#{dir}"`
          raise 'Failed to exec' unless $CHILD_STATUS.success?
          Dir[File.join(dir, '*')].each do |f|
            mail.add_file(filename: File.basename(f), content: File.read(f))
          end
        end
      end
      mail.deliver! unless @opts[:dry]
      total += 1
      puts "#{Rainbow('done').green} ##{total}"
    end
    puts "Processed #{sent.size} emails"
  end
end
