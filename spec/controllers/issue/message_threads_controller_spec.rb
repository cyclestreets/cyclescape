require 'spec_helper'

describe Issue::MessageThreadsController do
  let(:thread) { create(:message_thread, :belongs_to_issue) }
  let!(:message_a) { create(:message, thread: thread, created_at: Time.now - 4.days) }

  it 'has index' do
    get :index, issue_id: thread.issue.id
    expect(response.status).to eq(200)
  end
end



