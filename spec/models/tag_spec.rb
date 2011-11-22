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
end
