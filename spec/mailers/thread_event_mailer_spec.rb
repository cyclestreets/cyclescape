require 'spec_helper'

describe ThreadEventMailer do
  let(:thread)      { create :message_thread, subscribers: [user], leaders: [user] }
  let(:user)        { create :user }

  describe 'new leader' do
    it 'has correct text in email' do
      subject = described_class.send(:common, thread, 'new_leader', user, user)
      expect(subject.body).to include("set themself as a Leader of Message Thread")
    end
  end
end
