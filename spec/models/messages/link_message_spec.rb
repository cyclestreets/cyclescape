# frozen_string_literal: true

# == Schema Information
#
# Table name: link_messages
#
#  id            :integer          not null, primary key
#  thread_id     :integer          not null
#  message_id    :integer          not null
#  created_by_id :integer          not null
#  url           :text             not null
#  title         :string(255)
#  description   :text
#  created_at    :datetime
#

require "spec_helper"

describe LinkMessage do
  describe "associations" do
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:message) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:url) }
  end

  context "URLs" do
    subject { LinkMessage.new }

    it "should allow a valid URL with HTTP protocol" do
      subject.url = "http://en.wikipedia.org/wiki/Family_Guy"
      expect(subject).to have(0).errors_on(:url)
    end

    it "should allow a valid URL with HTTPS protocol" do
      subject.url = "https://en.wikipedia.org/wiki/Family_Guy"
      expect(subject).to have(0).errors_on(:url)
    end

    it "should allow a valid URL without protocol" do
      subject.url = "en.wikipedia.org/wiki/Family_Guy"
      expect(subject).to have(0).errors_on(:url)
    end

    it "should prefix the HTTP protocol on a URL without protocol" do
      subject.url = "en.wikipedia.org/wiki/Family_Guy"
      expect(subject.url).to eq("http://en.wikipedia.org/wiki/Family_Guy")
    end

    it "should not allow a URL with FTP protocol" do
      subject.url = "ftp://en.wikipedia.org/wiki/Family_Guy"
      expect(subject).to have(1).error_on(:url)
    end

    it "should not allow an invalid URL" do
      subject.url = "w[iki]pedia.org/wiki/Family_Guy"
      expect(subject).to have(1).error_on(:url)
    end
  end
end
