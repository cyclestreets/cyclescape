# == Schema Information
#
# Table name: user_prefs
#
#  id                              :integer         not null, primary key
#  user_id                         :integer         not null
#  notify_subscribed_threads       :boolean         default(TRUE), not null
#  notify_new_home_locations_issue :boolean         default(FALSE), not null
#  notify_new_group_thread         :boolean         default(TRUE), not null
#  notify_new_issue_thread         :boolean         default(FALSE), not null
#

require 'spec_helper'

describe UserPref do
  it { should belong_to(:user) }

  describe "attributes" do
    booleans = %w(
      notify_subscribed_threads
      notify_new_user_locations_issue
      notify_new_group_thread
      notify_new_issue_thread
      )

    booleans.each do |attr|
      it "should respond to #{attr} with true or false" do
        subject.send(attr).should_not be_nil
      end
    end
  end
end
