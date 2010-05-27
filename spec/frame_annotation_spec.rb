$: << File.expand_path(File.dirname(__FILE__))
require 'spec_helper'

describe "frame annotations" do
  before do
    @obj = CineSync::FrameAnnotation.new(5)
  end

  it "should validate frame number" do
    @obj.frame.should == 5
    @obj.should.be.valid?
    CineSync::FrameAnnotation.new(0).should.not.be.valid? # 1-based, so 0 is invalid
    CineSync::FrameAnnotation.new(-5).should.not.be.valid?
    CineSync::FrameAnnotation.new("three").should.not.be.valid?
  end

  it "should store notes" do
    @obj.notes.should == ""
    @obj.notes = "asdf"
    @obj.notes.should == "asdf"
    @obj.should.be.valid?
  end

  it "should start with no drawing objects" do
    @obj.drawing_objects.should.be.empty?
  end

  it "should start in default state" do
    @obj.should.be.default?
    @obj.notes = "asdf"
    @obj.should.not.be.default?
  end
end
