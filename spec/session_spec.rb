$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

describe "cineSync session" do
  before do
    @obj = CineSync::Session.new
  end

  it "should have current file version" do
    @obj.file_version.should == 3
    @obj.should.be.valid?
  end

  it "should have standard features by default" do
    @obj.session_features.should == :standard
  end

  it "should store user data" do
    @obj.notes.should.not.be.nil?
    @obj.notes.should.be.empty?
    @obj.user_data = "My custom data"
    @obj.user_data.should == "My custom data"
  end

  it "should have a groups array" do
    @obj.groups.should == []
    @obj.groups << "My group"
    @obj.groups.should == ["My group"]
  end

  it "should store notes" do
    @obj.notes.should.not.be.nil?
    @obj.notes.should.be.empty?
    @obj.notes = "asdf"
    @obj.notes.should == "asdf"
  end

  it "should have an array of media" do
    @obj.media.should == []
  end
end
