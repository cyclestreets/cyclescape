# frozen_string_literal: true

require "spec_helper"

describe Notifications do
  let(:group)         { group_profile.group }
  let(:user)          { gm.user }
  let!(:gm)           { create :group_membership, group: group }
  let(:group_profile) { create :group_profile, new_user_email: "big hello to {{full_name}} nothing to {{see}} here" }

  it "interpolates the {{full_name}} only" do
    subject = described_class.send(:added_to_group, gm)
    expect(subject.body).to include("big hello to #{user.full_name} nothing to  here")
  end

  describe "thread deadlines" do
    let(:deadline) { create :deadline_message, deadline: Time.utc(2020, 6, 1, 10) } # 10am UTC is 11am BST

    it "sets the correct timezone" do
      subject = described_class.upcoming_thread_deadline(deadline.created_by, deadline.message.thread, deadline)
      expect(subject.body).to include("June 1st, 2020 11:00")
    end
  end

  describe "issue deadlines" do
    let(:issue)  { create :issue, deadline: Time.utc(2020, 6, 1, 10) } # 10am UTC is 11am BST
    let(:thread) { create :message_thread, issue: issue }

    it "sets the correct timezone" do
      subject = described_class.upcoming_issue_deadline(issue.created_by, issue, thread)
      expect(subject.body).to include("June 1st, 2020 11:00")
    end
  end
end
