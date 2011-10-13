# == Schema Information
#
# Table name: messages
#
#  id             :integer         not null, primary key
#  created_by_id  :integer         not null
#  thread_id      :integer         not null
#  body           :text            not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  deleted_at     :datetime
#

require 'spec_helper'

describe Message do
  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:thread) }
    it { should belong_to(:component) }
  end

  describe "validations" do
    it { should validate_presence_of(:created_by_id) }
    it { should validate_presence_of(:body) }
  end

  describe "component association" do
    subject { FactoryGirl.create(:message) }

    it "should accept a PhotoMessage" do
      subject.component = FactoryGirl.create(:photo_message, message: subject)
      subject.component_type.should == "PhotoMessage"
      subject.should be_valid
    end
  end
end
