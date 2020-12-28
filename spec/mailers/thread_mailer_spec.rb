# frozen_string_literal: true

require "spec_helper"

describe ThreadMailer do
  let(:user)          { membership.user }
  let(:message_one)   { create(:message, created_by: user, thread: thread) }
  let(:message_two)   { create(:message, created_by: user, in_reply_to: message_one, thread: thread) }
  let(:message_three) { create(:message, created_by: user, in_reply_to: message_two, thread: thread) }
  let(:message_all_components) { message_three }
  let(:created_by_user) { create(:group_membership, :committee, group: group).user }
  let(:thread)        { create :message_thread, group: group, privacy: privacy, created_by: created_by_user }
  let(:privacy)       { "group" }
  let(:membership)    { create :brian_at_quahogcc }
  let(:group)         { membership.group }
  let(:cs_photo)      { create(:cyclestreets_photo_message, created_by: user, message: message_all_components) }
  let(:deadline)      { create(:deadline_message, created_by: user, message: message_all_components, thread: thread) }
  let(:document)      { create(:document_message, created_by: user, message: message_all_components, thread: thread) }
  let(:library)       { create(:library_item_message, :with_document, created_by: user, message: message_all_components, thread: thread) }
  let(:link)          { create(:link_message, created_by: user, message: message_all_components, thread: thread) }
  let(:photo)         { create(:photo_message, created_by: user, message: message_all_components, thread: thread) }
  let(:poll)          { create(:poll_message, :with_options, created_by: user, message: message_all_components) }
  let(:leader)        { create(:thread_leader_message, created_by: user, message: message_all_components, thread: thread) }
  let(:street_view)   { create(:street_view_message, created_by: user, message: message_all_components, thread: thread) }

  before do
    thread.add_subscriber user
  end

  describe "normal message" do
    context "when subscriber in is multiple groups" do
      before { create :group_membership, user: user }

      it "adds the groups to the email subject" do
        subject = described_class.common(message_one.reload, user)
        expect(subject.subject).to eq(
          I18n.t(
            "mailers.thread_mailer.common.subject",
            title: thread.title, count: 1, application_name: SiteConfig.first.application_name,
            group_name: "[#{group.name}]"
          )
        )
      end

      it "does not add the group for non-group threads" do
        message_one.reload.thread.update!(group: nil, privacy: MessageThread::PRIVATE)
        subject = described_class.common(message_one, user)
        expect(subject.subject).to eq(
          I18n.t(
            "mailers.thread_mailer.common.subject",
            title: thread.title, count: 1, application_name: SiteConfig.first.application_name,
            group_name: nil
          )
        )
      end
    end
  end

  describe "new document messages" do
    it "has correct text in email" do
      document
      subject = described_class.common(message_all_components.reload, user)

      expect(subject.subject).to eq(
        I18n.t(
          "mailers.thread_mailer.common.subject",
          title: thread.title, count: 2, application_name: SiteConfig.first.application_name,
          group_name: nil
        )
      )
      expect(subject.text_part.decoded).to include("Brian#{I18n.t('.thread_mailer.header.committee')}")
      expect(subject.text_part.decoded).to include(I18n.t(".thread_mailer.new_document_message.view_the_document"))
      expect(subject.text_part.decoded).to include("#{root_url[0..-2]}#{document.file.url}")
      expect(subject.to).to include(user.email)
      expect(subject.header["Reply-To"].value).to eq("<message-#{message_three.public_token}@cyclescape.org>")
      expect(subject.header["Message-ID"].value).to eq("<message-#{message_three.public_token}@cyclescape.org>")
      expect(subject.header["References"].value).to eq(
        "<thread-#{thread.public_token}@cyclescape.org> <message-#{message_one.public_token}@cyclescape.org> <message-#{message_two.public_token}@cyclescape.org>"
      )
    end
  end

  describe "new deadline message" do
    let(:privacy) { "committee" }
    it "has attachment" do
      deadline
      subject = described_class.common(message_all_components.reload, user)
      expect(subject.subject).to eq(
        I18n.t(
          "mailers.thread_mailer.common.committee_subject",
          title: thread.title, count: 2, application_name: SiteConfig.first.application_name,
          group_name: nil
        )
      )
      expect(subject.attachments.first.body.to_s.start_with?("BEGIN:VCALENDAR")).to eq(true)
    end
  end

  describe "digest" do
    before do
      [cs_photo, deadline, document, library, link, photo, poll, leader, street_view]
    end

    it "works with all message components" do
      (Message::COMPONENT_TYPES - %i[street_view_messages map_messages action_messages]).each do |component_type|
        expect(message_all_components.public_send(component_type)).to(
          be_present, "expected message to have #{component_type} but it did not"
        )
      end

      subject = described_class.digest(user, thread.reload => [message_one, message_all_components.reload])
      expect(subject.text_part.decoded).to include("#{root_url[0..-2]}#{document.file.url}")
      expect(subject.text_part.decoded).to include("To reply to the message above")
      expect(subject.subject).to include("Digest for")
      expect(subject.reply_to.first).to include("no-reply")
    end
  end
end
