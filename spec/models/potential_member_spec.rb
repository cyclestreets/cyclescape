require 'spec_helper'

describe PotentialMember, type: :model do
  it { is_expected.to belong_to(:group) }
  it { is_expected.to validate_presence_of(:group) }
  it { is_expected.to validate_presence_of(:email_hash) }

  it "sets the email hash when email is set" do
    expect{ subject.email = "me@example.com" }.to change { subject.email_hash }
  end

  it "has email_eq scope" do
    subject = create :potential_member, email: "me@example.com"
    expect(described_class.email_eq("me@example.com")).to eq [subject]
  end
end
