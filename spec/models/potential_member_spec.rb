require 'spec_helper'

describe PotentialMember, type: :model do
  let(:group) { build_stubbed :group }
  it { is_expected.to belong_to(:group) }
  it { is_expected.to validate_presence_of(:group) }
  it { is_expected.to validate_presence_of(:email_hash) }

  it "sets the email hash when email is set" do
    expect{ subject.email = "me@example.com" }.to change { subject.email_hash }
  end

  it "deals with emails in 'Name <email@example.com>' format" do
    subject.email = "me@example.com"
    expect{ subject.email = "Me <me@example.com>" }.to_not change { subject.email_hash }
    expect{ subject.email = "Me <me@another.example.com>" }.to change { subject.email_hash }
  end

  it "validates the address is valid" do
    subject.email = "meexample.com"
    expect(subject.errors_on(:email)).to eq ["'meexample.com' is an invalid format for an email address"]
  end

  it "is valid if the email exists once only" do
    subject = group.potential_members.build(group: group, email: "me@example.com")
    expect(subject.errors_on(:email)).to be_blank
  end

  it "validates the hash is uniq per group" do
    group.potential_members.build(email: "me@example.com")
    subject = group.potential_members.build(group: group, email: "me@example.com")
    expect(subject.errors_on(:email)).to eq ["'me@example.com' is being added twice"]
  end

  it "has email_eq scope" do
    subject = create :potential_member, email: "me@example.com"
    expect(described_class.email_eq("me@example.com")).to eq [subject]
  end
end
