# cineSync RubyGem

## Notice: old and unsupported!

**This repository is now deprecated and unsupported. Please instead use see the [downloads on the cineSync website](http://cinesync.com/downloads).**

## Integration Overview

### Commands and Events

cineSync 3.0 introduced new features to integrate with the production pipeline. This is achieved with two concepts: commands and events.

![Commands and Events](http://www.cinesync.com/files/api_commands_events.png)

**Commands** are sent by other applications to cineSync. A command is a URL with the `cinesync:` scheme, so they can be called from a web page or email, or sent by an application or script. Commands in cineSync 3.0:

- Joining a session
- Starting a new session
- Modifying the current session's content (adding new files, changing notes and annotations)
- Running a script configured in cineSync

The syntax for these is described in the command reference.

**Events** are triggered from within cineSync. These run commands, typically a Python or Ruby script. You can always run these manually, or also choose to have them run automatically when certain things change in cineSync. The triggered script has full access to the content of the session, along with some of the surrounding environment (the session key, etc.).

Running event scripts from cineSync requires a cineSync Pro account.

### The Session File

The cineSync session file format holds information about the contents of the session. This is the same format that is generated when selecting "Save Session" from within cineSync. This is an XML-based file, with the goal to represent the session as it was seen on the local computer.

*Backward compatibility note:* The session file format has changed significantly with cineSync 3. cineSync 3 can open sessions saved by older versions of cineSync, but will only write the v3 format.

When cineSync runs a command via an event, it serializes the current session and pipes it to the command. The script can examine the current playlist, notes, annotations, and so on, so it could save them to a shared production database, or access additional information about the active movie.

Additionally, an external script can call a `cinesync:` URL, giving it the path to a session file on disk. cineSync will then open this file and add its contents to the session. This allows creating a session from an external tool, or adding notes from external sources.

The cineSync API libraries (Ruby and Python) provide methods for manipulating and generating the session file format. From other languages, you can manipulate the XML structure directly.

#### User Data

A typical integration of cineSync into the production pipeline involves starting a session from shots in a database. Once the session is finished, any notes and annotations are saved back into the database and linked to the original shots. The production database typically refers to each file differently than cineSync does. cineSync tracks the path to each QuickTime movie, whereas the database might use a shot ID.

To link notes from cineSync back to the shot in the database, you need to know this shot ID. The script that starts the session can store this as *user data*. This is a custom string that can be attached to each file in the playlist. When exporting from cineSync, an event handler script can use this to determine how to link everything back to the database.

You can also attach user data to the session as a whole.

User data is propagated to all clients in the session.

### Event Handler Environment

When cineSync runs a script, it calls it with arguments describing the current environment: the session key, saved frame folder and format. The API provides a standard event handler block that parses these arguments and reads the session file, presenting them as native objects to the rest of the Ruby or Python script. See below for event handler examples.

## Getting Started
### Installing the Gem

Install the cineSync gem with `gem install cinesync`. The following examples are marked as "command" or "event handler". Those marked "command" can be run from a shell, or from another application. Scripts marked as "event handler" should be set up in cineSync's preferences and run from the *Session* &gt; *Run Script* menu.

### Joining an Existing Session (command)

This example shows how to join a session, with the key passed as a command-line argument. Save the script as `join.rb` and call it as:
`ruby join.rb ASDF1234` (using a valid session key).

    require 'rubygems'
    require 'cinesync'
    key = ARGV[0]
    CineSync::Commands.join_session! key

### Creating a Session (command)

This script creates a session with a single media file, linked to an HTTP URL. Once in cineSync, you will be given the option to download it (or locate it locally).

You can also give a local file path to the MediaFile constructor.


    require 'rubygems'
    require 'cinesync'

    s = CineSync::Session.new
    s.media << CineSync::MediaFile.new("http://cinesync.com/files/sample_qt.mov")
    CineSync::Commands.open_session! s

### Email a Session Invitation (event handler)

The following script sends an email containing the current session key as a clickable link. (This script is also in the examples folder.)

    require 'rubygems'
    require 'cinesync'
    require 'net/smtp'

    CineSync.event_handler do |evt|
      exit if evt.offline?

      join_url = CineSync::Commands.join_session(evt.session_key)
      server, from, to = ARGV[0..2]
      msg = "From: #{from}\nTo: #{to}\n" +
            "Subject: Join my cineSync session: #{evt.session_key}\n\n" +
            "Come join my cineSync session! Just click here: <#{join_url}>\n"

      Net::SMTP.start(server) {|s| s.send_message(msg, from, to) }
    end

In cineSync, add a script with the command:

    /usr/bin/ruby /path/to/invite.rb smtp.example.com from_me@example.com my_friend@example.com

Adjust the path to the script, and the path to Ruby (on Windows it will be similar to `C:\Ruby\bin\ruby.exe`). Replace the email addresses and SMTP server as necessary.

### Export Notes to CSV (event handler)

This script is in the `examples` folder of the repository. It will create a CSV file including all notes from the session (frame, media file, and session).

In cineSync, add a script with the command:

    /usr/bin/ruby "/path/to/Export Notes to CSV.rb"

As above, adjust the path to the script, and the path to Ruby.

## Support

If you have any questions using the cineSync Ruby library, or with the cineSync integration features in general, please contact [support@cinesync.com](mailto:support@cinesync.com).

## Links

 * [cineSync homepage](http://cinesync.com/)
 * [cineSync support email](mailto:support@cinesync.com)

## Files

 * `cineSync Session v3 Schema.rnc`: Session XML schema in [RELAX NG](http://relaxng.org/) Compact syntax

## Copyright

Copyright (c) 2010 Rising Sun Research Pty Ltd. See LICENSE for details.
