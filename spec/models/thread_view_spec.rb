require 'spec_helper'

describe ThreadView do
  context 'newly created' do
    subject { FactoryGirl.create(:thread_view) }

    it 'should be valid' do
      expect(subject).to be_valid
    end

    it 'should have a time of last view' do
      expect(subject.viewed_at).to be_a(Time)
    end
  end
end
