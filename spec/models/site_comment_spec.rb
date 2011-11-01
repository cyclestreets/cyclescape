require 'spec_helper'

describe SiteComment do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:body) }

    it "should only allow a valid URL" do
      comment = SiteComment.new
      comment.context_url = "http://www.example.com"
      comment.should have(0).errors_on(:context_url)
      comment.context_url = "blah"
      comment.should have(1).error_on(:context_url)
    end
  end

  context "viewing" do
    subject { FactoryGirl.create(:site_comment) }

    it "should update the viewed timestamp when viewed" do
      subject.viewed_at.should be_nil
      subject.viewed!
      subject.viewed_at.should_not be_nil
    end

    it "should respond to viewed?" do
      subject.viewed?.should be_false
      subject.viewed!
      subject.viewed?.should be_true
    end
  end
end
