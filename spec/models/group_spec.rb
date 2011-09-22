require 'spec_helper'

describe Group do
  describe "to be valid" do
    subject { Factory.build(:group) }

    it "must have a name" do
      subject.name = ""
      subject.should have(1).error_on(:name)
    end

    it "must have a short name" do
      subject.short_name = ""
      subject.should have(1).error_on(:short_name)
    end
  end
end
