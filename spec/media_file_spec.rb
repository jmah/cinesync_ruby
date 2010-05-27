$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

shared "single and group movie" do
  it "should store user data" do
    @obj.user_data.should.not.be.nil?
    @obj.user_data.should.be.empty?
    @obj.user_data = "My custom data"
    @obj.user_data.should == "My custom data"
    @obj.should.be.valid?
  end

  it "should have an active property" do
    @obj.should.not.be.active?
    @obj.active = true
    @obj.should.be.active?
    @obj.should.be.valid?
  end

  it "should track the current frame" do
    @obj.current_frame.should == 1
    @obj.current_frame = 99
    @obj.current_frame.should == 99
    @obj.should.be.valid?

    @obj.current_frame = -1
    @obj.current_frame.should == -1
    @obj.should.not.be.valid?
  end

  it "should belong to groups" do
    @obj.groups.should.be.empty?
    @obj.groups << "My group"
    @obj.groups.should.be == ["My group"]
  end
end


describe "cineSync media file" do
  before do
    @obj = CineSync::MediaFile.new("ftp://ftp.cinesync.com/demo.mov")
  end

  behaves_like "single and group movie"

  it "should be valid by default" do
    @obj.should.be.valid?
  end

  it "should create annotations on demand" do
    @obj.annotations.should.be.empty?
    ann_on_demand = @obj.annotations[32]
    ann_on_demand.should.not.be.nil?
    ann_on_demand.notes.should.not.be.nil?
    ann_on_demand.notes.should.be.empty?

    # Check that the instance we have is shared with the annotations hash
    ann_on_demand.notes = 'notes on frame 32'
    @obj.annotations[32].notes.should == ann_on_demand.notes
  end

  it "should validate annotation frame number" do
    ann = @obj.annotations[3]
    ann.should.be.valid?
    @obj.should.be.valid?

    ann2 = @obj.annotations[-5]
    ann2.should.not.be.valid?
    @obj.should.not.be.valid?
    @obj.annotations.delete(-5)
    @obj.should.be.valid?
  end

  it "should require a locator for validity" do
    mf_loc = CineSync::MediaFile.new("/Volumes/Oyama/Streams/cineSync Test Files/movies/nasa_shuttle_m420p.mov")
    mf_loc.should.be.valid?
    mf_noloc = CineSync::MediaFile.new
    mf_noloc.should.not.be.valid?
  end

  it "should get name from locator" do
    @obj.name.should == "demo.mov"

    @obj.name = ""
    @obj.name.should.be.empty?
    @obj.should.not.be.valid?

    @obj.name = "custom_name"
    @obj.name.should == "custom_name"
    @obj.should.be.valid?

    CineSync::MediaFile.new.name.should == ""
  end
end


describe "group movies" do
  before do
    @obj = CineSync::GroupMovie.new("grp")
  end

  behaves_like "single and group movie"

  it "should be based on a group" do
    @obj.group.should == "grp"
    @obj.should.be.valid?

    @obj.group = ""
    @obj.group.should.be.empty?
    @obj.should.not.be.valid?
  end

  it "should accept all files group" do
    empty = CineSync::GroupMovie.new("")
    empty.group.should == ""
    empty.should.not.be.valid?

    empty.group = CineSync::AllFilesGroup
    empty.should.be.valid?
  end

  it "should trigger pro features" do
    @obj.should.uses_pro_features?
  end
end
