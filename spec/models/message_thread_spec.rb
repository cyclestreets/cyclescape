# frozen_string_literal: true


require "spec_helper"

describe MessageThread do
  it_should_behave_like "a taggable model"
  let(:messages) { thread.reload.messages }

  describe "associations" do
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:issue) }
    it { is_expected.to have_many(:messages) }
    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_many(:thread_leader_messages) }
    it { is_expected.to have_many(:leaders) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:created_by) }
    it { is_expected.to allow_value("public").for(:privacy) }
    it { is_expected.to allow_value("group").for(:privacy) }
    it { is_expected.to allow_value("committee").for(:privacy) }
    it { is_expected.not_to allow_value("other").for(:privacy) }
  end

  it "should validate the owner group if the privacy is group" do
    subject.privacy = "group"
    expect(subject.errors_on(:group)).to eq ["can't be blank"]
    subject.privacy = "public"
    expect(subject.errors_on(:group)).to be_blank
  end

  it "should validate the creator is not disabled" do
    user = create :user
    subject.created_by = user
    expect(subject.errors_on(:base)).to be_empty
    user.update disabled_at: Time.zone.now
    expect(subject.errors_on(:base)).to eq([I18n.t("activerecord.errors.models.message_thread.attributes.base.disabled")])
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let!(:thread_from) { create(:message_thread, privacy: "private", created_by: user) }
    let!(:thread_to)   { create(:message_thread, privacy: "private", user: user) }

    it "has private_for" do
      expect(described_class.private_for(user)).to match_array [thread_from, thread_to]
    end

    it ".unviewed_for" do
      # with no thread views
      create(:message, thread: thread_from)
      create(:message, thread: thread_to)
      expect(described_class.unviewed_for(user)).to match_array [thread_to, thread_from]

      # with one recent thread view
      create :thread_view, thread: thread_to, viewed_at: 1.hour.ago, user: thread_to.created_by
      user_view = create :thread_view, thread: thread_to, viewed_at: 1.hour.ago, user: user
      create :thread_view, thread: thread_from, viewed_at: 1.hour.from_now, user: thread_to.created_by
      create :thread_view, thread: thread_from, viewed_at: 1.hour.from_now, user: user
      expect(described_class.unviewed_for(user)).to eq [thread_to]

      # where both threads have been viewed recently
      user_view.update_column(:viewed_at, 1.hour.from_now)
      expect(described_class.unviewed_for(user)).to eq []
    end

    context "with upcoming deadlines" do
      let(:deadline_soon) { create(:message_thread) }
      let(:deadline_further) { create(:message_thread) }
      let(:deadline_past) { create(:message_thread) }
      let(:deadline_censored) { create(:message_thread) }

      before do
        create(:deadline_message, message: create(:message, thread: deadline_soon), deadline: 2.hours.from_now)
        create(:deadline_message, message: create(:message, thread: deadline_soon), deadline: 20.hours.from_now)
        create(:deadline_message, message: create(:message, thread: deadline_soon), deadline: 1.hour.ago)

        create(:deadline_message, message: create(:message, thread: deadline_further), deadline: 4.hours.from_now)
        create(:deadline_message, message: create(:message, thread: deadline_further), deadline: 5.hours.from_now)

        create(:deadline_message, message: create(:message, thread: deadline_past), deadline: 2.hours.ago)

        create(:deadline_message, message: create(:message, thread: deadline_censored, censored_at: Time.current), deadline: 1.hour.from_now)
      end

      it ".with_upcoming_deadlines" do
        expect(described_class.with_upcoming_deadlines).to eq([deadline_soon, deadline_further])
      end
    end
  end

  describe "privacy" do
    subject { MessageThread.new }

    it "should become private to group" do
      expect(subject).not_to be_private_to_group
      subject.group = create(:group)
      subject.privacy = "group"
      expect(subject).to be_private_to_group
      expect(subject).not_to be_private_to_committee
      expect(subject).not_to be_public
    end

    it "should become private to committee" do
      expect(subject).not_to be_private_to_committee
      subject.group = create(:group)
      subject.privacy = "committee"
      expect(subject).to be_private_to_committee
      expect(subject).not_to be_private_to_group
      expect(subject).not_to be_public
    end

    it "should be public" do
      expect(subject).not_to be_public
      subject.privacy = "public"
      expect(subject).to be_public
    end
  end

  describe "participants" do
    it "should have zero participants" do
      thread = create(:message_thread)
      expect(thread.participants.count(:id)).to eq(0)
    end

    it "should have one participant" do
      thread = create(:message_thread_with_messages)
      expect(thread.participants.count(:id)).to eq(1)
    end
  end

  describe "priorities" do
    let(:user) { create(:user) }
    let(:thread) { create(:message_thread) }
    let!(:priority) { create(:user_thread_priority, user: user, thread: thread) }

    it "should confirm that user has prioritised" do
      expect(thread.priority_for(user)).to eq(priority)
    end
  end

  describe "with messages from" do
    let(:user) { create(:user) }
    let(:thread) { create(:message_thread) }
    let(:message) { create(:message, thread: thread, created_by: user) }

    it "should be empty" do
      expect(MessageThread.with_messages_from(user)).to be_empty
    end

    it "should find one thread" do
      message
      expect(MessageThread.with_messages_from(user).count).to eq(1)
    end

    it "should only find one thread with multiple messages from the same user" do
      message
      create(:message, thread: thread, created_by: user) # second message in same thread
      expect(MessageThread.with_messages_from(user).count).to eq(1)
    end
  end

  describe "upcoming deadlines" do
    let(:thread) { create(:message_thread) }
    let!(:deadline_message_old) { create(:deadline_message, message: create(:message, thread: thread), deadline: Time.current - 10.days) }
    let!(:deadline_message_soon) { create(:deadline_message, message: create(:message, thread: thread), deadline: Time.current + 2.days) }
    let!(:deadline_message_later) { create(:deadline_message, message: create(:message, thread: thread), deadline: Time.current + 100.days) }

    it "should return deadline messages in order" do
      messages = thread.upcoming_deadline_messages
      expect(messages).to eq [deadline_message_soon.message, deadline_message_later.message]
    end
  end

  describe ".order_by_latest_message" do
    it "should return threads with most recent messages first" do
      threads = create_list(:message_thread, 3, :with_messages)
      found = MessageThread.order_by_latest_message
      expect(found).to eq(threads.reverse)
      expect(found.first.latest_message.created_at).to be > found.last.latest_message.created_at

      changed_message = threads[1].messages.first
      changed_message.update(created_at: 1.hour.from_now)
      expect(MessageThread.order_by_latest_message).to_not eq(threads.reverse)
      changed_message.update_column(:status, "mod_queued")
      expect(MessageThread.order_by_latest_message).to eq(threads.reverse)
    end
  end

  it "#latest_activity_at" do
    thread = create(:message_thread, :with_messages)
    newest_message = thread.messages.last
    tomorrow = 1.day.from_now
    newest_message.update(updated_at: tomorrow)
    expect(thread.latest_activity_at).to be_within(1).of tomorrow
    newest_message.update_column(:status, "mod_queued")
    expect(thread.latest_activity_at).to_not eq tomorrow
  end

  context "public token" do
    it "should be set after being created" do
      thread = create(:message_thread)
      expect(thread.public_token).to be_truthy
    end

    it "should be a 10 digit alphanumeric string" do
      thread = create(:message_thread)
      expect(thread.public_token).to match(/\A[0-9a-f]{20}\Z/)
    end

    it "should be set by set_public_token" do
      thread = create(:message_thread)
      thread.public_token = ""
      expect(thread.public_token).to be_blank
      thread.send(:set_public_token)
      expect(thread.public_token).not_to be_blank
    end
  end

  describe "default_centre" do
    context "with deleted issue" do
      subject { create(:message_thread, :belongs_to_issue) }
      let!(:issue_centre) { subject.issue.centre }

      before { subject.issue.destroy }

      it "still has the issues' centre" do
        expect(subject.default_centre).to eq(issue_centre)
      end
    end

    context "with a group with a profile but no issue" do
      subject { create(:message_thread, group: group) }
      let(:group) { create :group, :with_profile }

      it "still has the groups' centre" do
        expect(subject.default_centre).to eq(subject.group.profile.centre)
      end
    end

    context "with a group with no profile, no issue, but created by a user with a profile" do
      let(:user) { create :user, :with_location }
      subject { create(:message_thread, created_by: user) }

      it "still has users' centre" do
        expect(subject.default_centre).to eq(user.location.centre)
      end
    end

    context "with a group with no profile, no issue, and created by a user without a profile" do
      subject { create(:message_thread) }

      it "has a random centre" do
        expect(subject.default_centre).to_not be_nil
      end
    end
  end

  describe "#add_message_from_email!" do
    let(:mail) { create(:inbound_mail) }
    let(:thread) { create(:message_thread_with_messages) }
    let!(:in_reply_to) { thread.messages.last }
    let(:new_message) { messages.last }

    it "should create a new message" do
      expect { thread.add_messages_from_email!(mail, nil) }.to change { thread.reload.messages.count }.by(1)
      expect(new_message).to be_a(Message)
      expect(new_message.body).not_to be_blank
      expect(new_message.approved?).to be true
      expect(new_message.inbound_mail).to eq(mail)
    end

    it "should re-open a closed thread" do
      thread.update_column(:closed, true)
      thread.add_messages_from_email!(mail, nil)
      expect(thread.reload.closed).to eq(false)
    end

    it "should add the in reply to" do
      expect { thread.add_messages_from_email!(mail, nil) }.to change { thread.reload.messages.count }.by(1)
      expect(new_message).to be_a(Message)
      expect(new_message.body).not_to be_blank
      expect(new_message.in_reply_to).to eq(in_reply_to)
    end

    it "should create a message with the user info" do
      expect { thread.add_messages_from_email!(mail, nil) }.to change { thread.reload.messages.count }.by(1)
      expect(new_message.created_by.name).to eq(mail.message.header[:from].display_names.first)
      expect(new_message.created_by.email).to eq(mail.message.header[:from].addresses.first)
    end

    context "signature removal" do
      it "should remove double-dash signatures" do
        allow(mail.message).to receive(:decoded).and_return("Normal text here\n\n--\nSignature")
        thread.add_messages_from_email!(mail, nil)
        expect(new_message.body).to eq("<p>Normal text here\n</p>")
      end
    end

    context "with HTML" do
      let(:mail) { create(:inbound_mail, :with_html) }

      it "should remove HTML signatures" do
        thread.add_messages_from_email!(mail, nil)
        expect(new_message.body).to eq("<p>\n  This email has an HTML message body and a plain link <a href=\"http://www.example.com\">www.example.com</a> .\n</p>\n<br>\n<p>\nNikolai\n</p>\n<br>\n\n")
      end

      context "html with <div> and <br>s" do
        let(:mail) { InboundMail.new(raw_message: File.read(raw_email_path("html_div_br"))) }
        it "should remove HTML signatures" do
          thread.add_messages_from_email!(mail, nil)
          expect(new_message.body).to eq("<p>I have lots of feedback from members now - thanks Anna.</p><p>Trying to figure out if I can put their names in the big presentation</p>\n")
        end
      end

      context "split by divs" do
        let(:mail) { InboundMail.new(raw_message: File.read(raw_email_path("html_div"))) }
        it "should remove HTML signatures" do
          thread.add_messages_from_email!(mail, nil)
          expect(new_message.body).to eq("<p>  Text split by divs</p><p>And not by p tags</p>\n")
        end
      end
    end

    context "with pgp sig" do
      let(:mail) { create(:inbound_mail, :with_pgp_sig) }

      it "should create one message" do
        expect { thread.add_messages_from_email!(mail, nil) }.to change { thread.reload.messages.count }.by(1)
        expect(new_message).to be_a(Message)
      end
    end

    context "with attachments" do
      let(:mail) { create(:inbound_mail, :with_attached_image) }
      let(:in_reply_to) { thread.messages.last }

      it "should create one messages" do
        expect { thread.add_messages_from_email!(mail, nil) }.to change { thread.reload.messages.count }.by(1)
        expect(new_message).to be_a(Message)
        expect(new_message.photo_messages.count).to eq 1
        expect(new_message.approved?).to be true
      end

      it "should add the in reply to" do
        thread.add_messages_from_email!(mail, in_reply_to)
        expect(new_message.in_reply_to).to eq(in_reply_to)
      end
    end
  end

  describe "#first_message" do
    let(:thread) { create(:message_thread_with_messages) }

    it "should return the oldest message on the thread" do
      expect(thread.first_message).to eq(thread.messages.order("created_at").first)
    end
  end

  describe "messages text" do
    let(:thread) { create(:message_thread_with_messages) }

    it "should return the text from all the messages" do
      thread.messages.each do |m|
        expect(thread.messages_text).to include(m.searchable_text)
      end
    end
  end

  describe "approve" do
    subject { create :message_thread, status: "mod_queued" }

    it "should only trigger subscription on first approval" do
      subject
      expect(ThreadSubscriber).to receive(:subscribe_users).once
      expect(ThreadNotifier).to receive(:notify_subscribers).once
      expect { subject.approve! }.to change { subject.reload.approved? }.from(false).to(true)
      subject.approve!
    end
  end

  describe "closing" do
    subject { create :message_thread }
    let(:user) { create :user }

    it "should save the event" do
      subject.close_by!(user)
      close_event = subject.message_thread_closes.last

      expect(close_event.event).to eq "closed"
      expect(close_event.user).to eq user
    end
  end

  describe ".to_icals" do
    subject { create :message_thread, title: "Important dates" }
    let(:message) { create :message, thread: subject }
    let!(:deadline) { create :deadline_message, message: message, title: "The AGM!", deadline: 1.day.from_now }

    it "has correct output" do
      ical = subject.to_icals[0]
      expect(ical.summary).to include("The AGM!")
      expect(ical.description).to include("Important dates")
      expect(ical.dtstart.to_i).to eq(deadline.deadline.to_i)
    end
  end

  describe "subscriptions" do
    let(:user) { create :user }

    it "subscribes creator" do
      thread = create :message_thread, created_by: user
      expect(thread.reload.subscribers).to eq [user]
    end

    it "subscribes creator" do
      message_to = create :user
      thread = create :message_thread, created_by: user, user: message_to
      expect(thread.reload.subscribers).to match_array [user, message_to]
    end
  end
end
