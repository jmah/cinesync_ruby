$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

describe "event handler" do
  before do
    @example_path = File.join("spec", "v3 files", "v3-basic.csc")
    @online_args = ["--key=ASDF0000", "--save-format=JPEG", "--save-dir=/tmp/cinesync"]
    @offline_args = ["--key=_OFFLINE_", "--save-format=PNG", "--save-dir=/tmp/cinesync"]
    @url_args = ["--key=URL1111", "--save-format=JPEG", "--url=cinesync://script/myscript?q=hi"]
    @handler_run = false
  end

  it "should load session from stdin" do
    File.open(@example_path, "r") do |f|
      CineSync.event_handler(@online_args, f) do |evt|
        evt.session.user_data.should == "sessionUserData blah bloo blee"
        evt.session.media.length.should == 3
        evt.session.notes.should == "These are my session notes.\nnewline."
        evt.session.should.be.valid?
        @handler_run = true
      end
    end
    @handler_run.should.be.true?
  end

  it "should parse online arguments" do
    File.open(@example_path, "r") do |f|
      CineSync.event_handler(@online_args, f) do |evt|
        evt.should.not.be.offline?
        evt.session_key.should == "ASDF0000"
        evt.save_format.should == :jpeg
        evt.save_parent.to_s.should == "/tmp/cinesync"
        evt.url.should.be.nil?
        @handler_run = true
      end
    end
    @handler_run.should.be.true?
  end

  it "should parse offline arguments" do
    File.open(@example_path, "r") do |f|
      CineSync.event_handler(@offline_args, f) do |evt|
        evt.should.be.offline?
        evt.session_key.should.be.nil?
        evt.save_format.should == :png
        evt.save_parent.to_s.should == "/tmp/cinesync"
        evt.url.should.be.nil?
        @handler_run = true
      end
    end
    @handler_run.should.be.true?
  end

  it "should parse url argument" do
    File.open(@example_path, "r") do |f|
      CineSync.event_handler(@url_args, f) do |evt|
        evt.should.not.be.offline?
        evt.session_key.should == "URL1111"
        evt.save_format.should == :jpeg
        evt.url.should == "cinesync://script/myscript?q=hi"
        @handler_run = true
      end
    end
    @handler_run.should.be.true?
  end
end
