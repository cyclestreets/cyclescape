require "spec_helper"

describe NewIssueNotifier do
  subject { NewIssueNotifier }

  let(:issue) { mock("issue", id: 99) }

  # Queueing interface
  it { should respond_to(:perform) }
  it { subject.queue.should == :outbound_mail }

  describe ".new_issue" do
    it "should queue process_new_issue with the issue ID" do
      Resque.should_receive(:enqueue).with(NewIssueNotifier, :process_new_issue, 99)
      subject.new_issue(issue)
    end
  end

  context "processing" do
    describe ".process_for_user_locations" do
      let(:user) { FactoryGirl.create(:user) }
      let(:issue) { FactoryGirl.create(:issue) }
      let(:location) { FactoryGirl.create(:user_location, loc_json: issue.loc_json, user: user) }

      before do
        user.prefs.update_attribute(:notify_new_user_locations_issue, true)
      end

      it "should add a buffer to the issue location"
      it "should find all user locations that intersect with the issue location"
      it "should queue a notification for each user that has preference set" do
        opts = {user_id: user.id, category_id: location.category_id, issue_id: issue.id}
        Resque.should_receive(:enqueue).with(NewIssueNotifier, :notify_new_user_location_issue, opts)
        subject.process_for_user_locations(issue)
      end
    end

    describe ".notify_new_user_location_issue" do
      # Hard to isolate and test
      it "should send a notification with the given user, issue, and category"
    end
  end
end
