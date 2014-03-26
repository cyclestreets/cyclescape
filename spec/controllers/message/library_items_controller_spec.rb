require 'spec_helper'

describe Message::LibraryItemsController do
  context 'as a site user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:library_item) { FactoryGirl.create(:library_item) }

    before do
      sign_in user
    end

    it 'should create a library item message' do
      post :create, library_item_message: { library_item_id: library_item.id },
                    message: { body: 'this is a useful item' },
                    thread_id: thread.id
      response.status.should be(200)
    end
  end
end
