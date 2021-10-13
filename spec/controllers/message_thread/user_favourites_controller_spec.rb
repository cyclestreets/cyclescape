# frozen_string_literal: true

require "spec_helper"

describe MessageThread::UserFavouritesController, type: :controller do
  let(:thread)   { create :message_thread }
  let(:user)     { create :user }

  before do
    warden.set_user user
  end

  describe "POST create.json" do
    subject { post :create, params: { thread_id: thread.id, format: :js } }

    it "should respond" do
      expect(subject.body).to include("Favourite saved")
      expect(thread.reload.favourite_for(user)).to be_persisted
    end
  end

  describe "DELETE destroy.json" do
    before do
      create :user_thread_favourite, thread: thread, user: user
    end

    subject { delete :destroy, params: { thread_id: thread.id, format: :js } }

    it "should respond" do
      expect(subject.body).to include("Favourite removed")
      expect(thread.reload.favourite_for(user)).to be_new_record
    end
  end
end
