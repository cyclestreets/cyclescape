# frozen_string_literal: true

require "spec_helper"

describe MessageThread::SubscriptionsController do
  let(:user) { create(:user) }
  let(:thread) { create(:message_thread) }

  before { warden.set_user user }

  it "does not keep the flash for the next page after a turbo stream subscribe" do
    post :create, params: { thread_id: thread.id }, format: :turbo_stream
    expect(flash[:success]).to be_present
    expect(flash.to_session_value).to be_nil
  end
end
