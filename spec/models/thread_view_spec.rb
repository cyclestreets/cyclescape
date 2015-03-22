# == Schema Information
#
# Table name: thread_views
#
#  id        :integer          not null, primary key
#  user_id   :integer          not null
#  thread_id :integer          not null
#  viewed_at :datetime         not null
#
# Indexes
#
#  index_thread_views_on_user_id                (user_id)
#  index_thread_views_on_user_id_and_thread_id  (user_id,thread_id) UNIQUE
#

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
