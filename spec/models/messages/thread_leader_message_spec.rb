require 'spec_helper'

describe ThreadLeaderMessage, type: :model do
  it { is_expected.to belong_to(:unleading) }

  let(:leader_message) { create :thread_leader_message }

  it "should validate user ownes unleading" do
    subject.unleading = leader_message
    expect(subject.errors_on(:base)).to eq(["Something went wrong"])

    subject.created_by = leader_message.created_by
    expect(subject.errors_on(:base)).to be_empty
  end
end
