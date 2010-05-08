#!/usr/bin/ruby
#
# This script reads the current session from cineSync and converts all notes
# made on the session, each media file, and each frame to a CSV file. This file
# can then be processed by other scripts or opened in a spreadsheet program
# (Microsoft Excel, OpenOffice.org Calc, Apple Numbers).
#

require 'rubygems'
require 'cinesync'
require 'csv'


CineSync.event_handler do |evt|
  name = "Notes from #{evt.offline? ? "offline session" : evt.session_key}.csv"
  path = CineSync::UI.prompt_to_save("Save CSV file as:", name)
  exit if path.nil? # User cancelled

  CSV.open(path, "w") do |csv|
    csv << ["Media File", "Frame", "Notes"] # Header row

    csv << ["", "[Session]", evt.session.notes] unless evt.session.notes.empty?

    evt.session.media.each do |media|
      csv << [media.name, "[Media File]", media.notes] unless media.notes.empty?
      media.annotations.keys.sort.each do |frame|
        ann = media.annotations[frame]
        next if ann.notes.empty?
        csv << [media.name, frame, ann.notes]
      end
    end
  end
end
