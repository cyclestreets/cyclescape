require 'spec_helper'

describe MessagesController do
  context 'as a site user' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
    end

    context 'user following link from email notification to file uploaded' do
      it 'should redirect to the Dragonfly location' do
        document = FactoryGirl.create(:document_message)
        get :show, id: document, thread_id: document.thread
      end
    end
  end
end