require 'spec_helper'

describe Issue do
  describe "to be valid" do
    subject { FactoryGirl.create(:issue) }

    it "must have a title" do
      subject.title = ""
      subject.should_not be_valid
    end
  end
end
