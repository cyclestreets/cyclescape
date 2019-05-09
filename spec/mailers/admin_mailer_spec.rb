# frozen_string_literal: true

require "spec_helper"

describe AdminMailer do
  let(:comment) { build_stubbed :site_comment }

  it "sends a comment email" do
    subject = described_class.new_site_comment comment
    expect(subject.subject).to eq "[ID #{comment.id}] New site comment"
    expect(subject.body).to include(comment.body)
  end
end
