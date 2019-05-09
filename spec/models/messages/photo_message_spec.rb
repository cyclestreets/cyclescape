# frozen_string_literal: true

# == Schema Information
#
# Table name: photo_messages
#
#  id            :integer          not null, primary key
#  thread_id     :integer          not null
#  message_id    :integer          not null
#  created_by_id :integer          not null
#  photo_uid     :string(255)      not null
#  caption       :string(255)
#  description   :text
#  created_at    :datetime         not null
#

require "spec_helper"

describe PhotoMessage do
  describe "associations" do
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:photo) }
  end

  context "factory" do
    subject { create(:photo_message) }

    it { is_expected.to be_valid }

    it "should have a thread" do
      expect(subject.thread).to be_a(MessageThread)
    end

    it "should have a message" do
      expect(subject.message).to be_a(Message)
    end
  end

  context "photo thumbnail" do
    subject { create(:photo_message) }

    it "should provide a thumbnail of the photo" do
      expect(subject.photo_thumbnail).to be_truthy
      expect(subject.photo_thumbnail.width).to eq(46)
      expect(subject.photo_thumbnail.height).to eq(50)
    end
  end

  context "photo preview" do
    subject { create(:photo_message) }

    it "should provide a preview size of the photo" do
      expect(subject.photo_preview).to be_truthy
      expect(subject.photo_preview.width).to eq(342)
      expect(subject.photo_preview.height).to eq(375)
    end
  end

  context "searchable text" do
    subject { create(:photo_message_with_description) }

    it "should contain the caption" do
      expect(subject.searchable_text).to include(subject.caption)
    end

    it "should contain the description" do
      expect(subject.searchable_text).to include(subject.description)
    end
  end
end
