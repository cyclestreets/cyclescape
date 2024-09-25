# frozen_string_literal: true

require "spec_helper"

describe Message do
  describe "validations" do
    it { is_expected.to validate_presence_of(:created_by) }
    it { is_expected.to validate_presence_of(:body) }

    it "removes empty paragraphs" do
      # \u00A0 is a non-breaking white space.
      is_expected.to normalize(:body).from(
        "<p>\r\nGot stuff in\r\n</p><p>&nbsp;<br></p><p>&nbsp;\r\n</p><p>And me</p><p> &nbsp; </p>\r\n<p>&nbsp; </p>\r\n<p>&nbsp;\u00A0</p>\r\n <p> &nbsp;</p>"
      ).to(
        "<p>\r\nGot stuff in\r\n</p><p>And me</p>"
      )
    end

    it do
      is_expected.to normalize(:body).from(
        "http://www.example.com?fbclid=123&this=that&other=other more words www.fb.com?p=q&fbclid=go\nhttp:fbclid"
      ).to(
        "http://www.example.com?other=other&this=that more words www.fb.com?p=q\nhttp:fbclid"
      )
    end

    it "should not require a body if a component is attached" do
      allow(subject).to receive(:components?).and_return(true)
      expect(subject).to have(0).errors_on(:body)
    end
  end

  describe ".after_date_with_n_before" do
    let!(:message_1) { create(:message, created_at: 4.hours.ago) }
    let!(:message_2) { create(:message, created_at: 3.hours.ago, thread: message_1.thread, created_by: message_1.created_by) }
    let!(:message_3) { create(:message, created_at: 2.hours.ago, thread: message_1.thread, created_by: message_1.created_by) }
    let!(:message_4) { create(:message, created_at: 1.hour.ago, thread: message_1.thread, created_by: message_1.created_by) }

    it do
      expect(message_1.thread.messages.approved.after_date_with_n_before(after_date: message_3.created_at, n_before: 1)).to eq [
        message_2, message_3, message_4
      ]
    end
  end

  describe "newly created" do
    subject { create(:message) }

    it "should not be censored" do
      expect(subject.censored_at).to be_nil
    end

    it "should have a public token" do
      expect(subject.public_token).to match(/\A[0-9a-f]{20}\Z/)
    end
  end

  describe "#component_name" do
    it "should return the name of Message" do
      message = build(:message)
      expect(message.component_name).to eq("message")
    end
  end

  describe "searchable text" do
    it "should return the body if there's no component" do
      message = create(:message)
      expect(message.searchable_text).to eq(message.body)
    end

    it "should return both the body and the component's text if there's a component" do
      photo_message = create(:photo_message)
      message = photo_message.message
      message.body = "Something here"
      expect(message.searchable_text).to include(message.body)
      expect(message.searchable_text).to include(photo_message.searchable_text)
    end
  end

  describe "in reply to" do
    let(:previous_message) { create(:message) }

    it "sets in reply to with previous message" do
      subject = create(:message, thread: previous_message.thread.reload)
      expect(subject.in_reply_to).to eq(previous_message)
    end

    it "errors when set to a message from a different thread" do
      subject = create(:message)
      subject.in_reply_to = previous_message
      expect(subject.errors_on(:in_reply_to_id).size).to eq(1)
    end

    it "sets in reply to nil with no previous message" do
      thread = build :message_thread
      message = thread.messages.build
      message.created_by = create :user
      message.body = "blah"
      thread.save
      expect(message.reload.in_reply_to_id).to eq nil
    end

    it "sets in reply to nil with no previous message" do
      thread = create :message_thread_with_messages
      last_message_id = thread.messages.last.id
      message = thread.messages.build
      message.created_by = create :user
      message.body = "blah"
      message.save
      expect(message.reload.in_reply_to_id).to eq last_message_id
    end
  end

  it "should have in group scope" do
    thread = create :message_thread, :belongs_to_group
    in_group = create :message, thread: thread
    create :message

    expect(described_class.in_group(thread.group.id)).to eq([in_group])

    expect(in_group.hashtags).to eq []
    in_group.update(body: "This #hashtag is #Great")
    expect(in_group.hashtags.pluck(:name)).to contain_exactly("hashtag", "great")
  end

  describe "states" do
    let(:user) { create :user, approved: false }
    let(:thread) { create :message_thread, status: thread_status }
    let!(:req) { stub_request(:post, %r{rest\.akismet\.com/1\.1/submit-ham}) }

    describe "skip_mod_queue!" do
      let(:thread_status) { "mod_queued" }

      subject { create :message, status: "mod_queued", thread: thread }
      it "should submit apporve thread" do
        expect { subject.skip_mod_queue! }.to change { thread.reload.approved? }.from(false).to(true)
        expect(subject.reload.approved?).to eq true
      end
    end

    describe "approved" do
      subject! { create :message, :possible_spam, created_by: user, thread: thread }

      context "with an mod_queued thread" do
        let(:thread_status) { "mod_queued" }

        it "should submit ham and apporve user and thread" do
          expect(thread).to receive(:approve!).once
          expect { subject.approve! }.to change { user.reload.approved }.from(false).to(true)
          expect(req).to have_been_made
        end
      end

      context "with an approved thread" do
        let(:thread_status) { "approved" }

        it "should submit ham, apporve user and notify subscribers" do
          expect(ThreadNotifier).to receive(:notify_subscribers).once
          expect { subject.approve! }.to change { user.reload.approved }.from(false).to(true)
          expect(req).to have_been_made
        end
      end
    end
  end

  describe "notification_name" do
    it { expect(subject.notification_name).to eq :new_message }
  end

  context "created_by a deleted user" do
    let(:user) { create :user, deleted_at: Time.current }
    subject { create :message, created_by: user }

    it "should still have a created_by" do
      expect(subject.reload.created_by).to eq user
    end
  end

  describe "#committee_created?" do
    let(:committee_membership) { create :brian_at_quahogcc }
    let(:group)                { committee_membership.group }
    let(:committee_member)     { committee_membership.user }
    let(:thread)               { build :message_thread, group: group }

    it "should identify committee members" do
      subject.created_by = committee_member
      expect(subject.committee_created?).to eq false
      subject.thread = thread
      expect(subject.committee_created?).to eq true
    end
  end
end
