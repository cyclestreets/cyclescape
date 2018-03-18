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
      allow_any_instance_of(Group::HashtagsController).to receive(:current_group).and_return(group)
    end

    describe 'show' do
      subject do
        get :show, name: hashtag.name
      end

      it { expect(subject.body).to include(thread.title) }
    end
  end
end
