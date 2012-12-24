# == Schema Information
#
# Table name: thread_views
#
#  id        :integer          not null, primary key
#  user_id   :integer          not null
#  thread_id :integer          not null
#  viewed_at :datetime         not null
#

require 'spec_helper'

describe ThreadView do
  context "newly created" do
    subject { FactoryGirl.create(:thread_view) }

    it "should be valid" do
      subject.should be_valid
    end

    it "should have a time of last view" do
      subject.viewed_at.should be_a(Time)
    end
  end
end
