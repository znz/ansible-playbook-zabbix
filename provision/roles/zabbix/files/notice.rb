#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# frozen_string_literal: true
require 'socket'
path = ARGV.shift
if ARGV.empty?
  abort("usage: #{$0} /path/to/sock message...")
end
begin
  stat = File.stat(path)
rescue Errno::EACCES
  stat = File.stat(File.dirname(path))
end
unless stat.writable?
  require 'etc'
  exec("sudo", "-u", Etc.getpwuid(stat.uid).name, $0, path, *ARGV)
end
UNIXSocket.open(path) do |s|
  ARGV.each do |message|
    s.puts message
  end
end
