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
