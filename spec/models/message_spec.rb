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
#  censored_at    :datetime
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

    it "should not require a body if a component is attached" do
      subject.stub(component: true)
      subject.should have(0).errors_on(:body)
    end
  end

  describe "newly created" do
    subject { FactoryGirl.create(:message) }

    it "should not be censored" do
      subject.censored_at.should be_nil
    end
  end

  describe "component association" do
    subject { FactoryGirl.create(:message) }

    it "should accept a PhotoMessage" do
      subject.component = FactoryGirl.create(:photo_message, message: subject)
      subject.component_type.should == "PhotoMessage"
      subject.should be_valid
    end
  end

  describe "body" do
    it "should be blank if empty when component is attached" do
      subject.stub(component: true)
      subject.created_by_id = 1
      subject.should be_valid
      subject.body.should == ""
    end

    it "should be retained with an attached component" do
      subject.stub(component: true)
      subject.created_by_id = 1
      subject.body = "Testing"
      subject.should be_valid
      subject.body.should == "Testing"
    end
  end

  describe "#component_name" do
    it "should return the name of Message if there is no component" do
      message = FactoryGirl.build(:message)
      message.component_name.should == "message"
    end

    it "should return the name of the component" do
      photo_message = FactoryGirl.build(:photo_message)
      message = photo_message.message
      message.component_name.should == "photo_message"
    end
  end

  describe "searchable text" do
    it "should return the body if there's no component" do
      message = FactoryGirl.create(:message)
      message.searchable_text.should == message.body
    end

    it "should return both the body and the component's text if there's a component" do
      message = FactoryGirl.create(:photo_message).message
      message.searchable_text.should include(message.body)
      message.searchable_text.should include(message.component.searchable_text)
    end
  end
end
