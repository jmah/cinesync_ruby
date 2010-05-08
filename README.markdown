# cineSync RubyGem

## Quick Start
### Installing the Gem

    gem install cinesync

### Creating a session file

    #!/usr/bin/ruby
    require 'rubygems'
    require 'cinesync'

    s = CineSync::Session.new
    s.media << CineSync::MediaFile.new("http://cinesync.com/files/sample_qt.mov")
    s.media << CineSync::MediaFile.new("/System/Library/Compositions/Fish.mov")
    File.open("/tmp/session.csc", "w") {|f| f << s.to_xml }


### Running in response to an event

    #!/usr/bin/ruby
    require 'rubygems'
    require 'cinesync'

    CineSync.event_handler do |evt|
      puts "cineSync online with key #{evt.session_key}" unless evt.offline?
      puts "Playlist has #{evt.session.media.length} files"
      active_file = evt.session.media.find {|m| m.active? }
      puts "Currently viewing #{active_file.name}" if active_file
    end


## Scripting Overview

cineSync 3.0 has new support for calling user-defined scripts. (Scripting requires a cineSync Pro account.) These are configured in cineSync's preferences. Scripts can be run from the Session &gt; Run Script menu, and can also be set to automatically trigger on certain events. When triggered, the script will be passed some arguments about the current environment (the current session key, where frames are being saved, and the save frame format), and the current session will be serialized and sent to it through standard I/O.

Additionally, a script can be run from a different application, set up a session, and send it to cineSync.

(More info to come: URLs etc)


## Links

 * [cineSync homepage](http://cinesync.com/)

## Files

 * `cineSync Session v3 Schema.rnc`: Session XML schema in [RELAX NG](http://relaxng.org/) Compact syntax

## Copyright

Copyright (c) 2010 Rising Sun Research Pty Ltd. See LICENSE for details.
