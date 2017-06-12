require 'spec_helper'

describe Group::HashtagsController, type: :controller do
  let(:thread)  { create :message_thread, :belongs_to_group, :with_messages }
  let(:group)   { thread.group }
  let(:message) { thread.messages.first }
  let(:hashtag) { create :hashtag, group: group }

  context 'when signed in' do
    before do
      message.hashtags << hashtag
      warden.set_user message.created_by
    end

    describe 'show' do
      subject { get :show, group_id: group.id, name: hashtag.name }

      it { expect(subject.status).to eq(200) }
    end
  end
end
