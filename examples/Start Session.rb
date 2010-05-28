#!/usr/bin/ruby

require 'rubygems'
require 'cinesync'

if ARGV.empty?
  $stderr.puts("Usage: #{$0} <file.mov> ...")
  exit 1
end


# Create the session and add media from command-line arguments
session = CineSync::Session.new
session.media = ARGV.map {|path| CineSync::MediaFile.new(path) }

# Open the session
CineSync::Commands.open_session!(session)
