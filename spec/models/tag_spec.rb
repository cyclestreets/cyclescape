require 'spec_helper'

describe Tag do
  it { should validate_presence_of(:name) }

  it "should set and return a name" do
    subject.name = "test"
    subject.name.should == "test"
  end

  it "should lowercase the name" do
    subject.name = "TeStINg"
    subject.name.should == "testing"
  end

  context "names" do
    let(:tags) { 4.times.map { Tag.create(name: FactoryGirl.generate(:tag)) } }

    it "should return the tag names as an array" do
      tags
      Tag.names.should == tags.map {|tag| tag.name }
    end
  end

  context "grab" do
    it "should return a tag with the correct name" do
      Tag.grab("spokes").name.should == "spokes"
    end

    it "should return a created Tag if it doesn't exist" do
      Tag.grab("wheels").should_not be_new_record
    end

    it "should return an existing tag if present" do
      existing = Tag.create(name: "pedals")
      found = Tag.grab("pedals")
      found.should == existing
    end

    it "should still make the tag lowercase" do
      Tag.grab("cHAiN").name.should == "chain"
    end

    it "should find the tag if given mixed case" do
      existing = Tag.create(name: "reflectors")
      found = Tag.grab("Reflectors")
      found.should == existing
    end
  end
end
