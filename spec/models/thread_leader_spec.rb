require 'spec_helper'

describe ThreadLeader, type: :model do
  it { is_expected.to belong_to(:message_thread) }
  it { is_expected.to belong_to(:user) }
end
