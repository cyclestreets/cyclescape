require 'spec_helper'

describe Issue::MessageThreadsController, type: :controller do
  let(:approved)   { false }
  let(:user)       { create :user, approved: approved }
  let(:thread)     { create :message_thread, issue: issue }
  let(:issue)      { create :issue, created_by: user }
  let!(:message_a) { create(:message, thread: thread, created_at: Time.now - 4.days) }

  it 'has index' do
    get :index, issue_id: thread.issue.id
    expect(response.status).to eq(200)
  end

  describe 'creating' do
    let(:message) { attributes_for(:message) }
    before do
      warden.set_user user
    end

    let!(:req) do
      stub_request(:post, /rest\.akismet\.com\/1\.1\/comment-check/).
        with(body: { blog: "http://www.cyclescape.org/",
                     comment_author: user.full_name,
                     comment_author_email: user.email,
                     comment_content: message[:body],
                     comment_type: "comment",
                     is_test: "1"}).to_return(status: 200, body: is_spam)
    end
    subject { post :create, issue_id: issue.to_param, thread: attributes_for(:message_thread), message: message }

    context 'with an unapproved user' do
      let(:is_spam) { 'false' }

      it 'should redirect home with flash' do
        expect(subject).to redirect_to('/home')
        expect(req).to have_been_made
        expect(flash[:alert]).to eq(t('issue.message_threads.create.not_approved'))
      end
    end

    context 'with an spam message' do
      let(:is_spam) { 'true' }

      it 'should redirect home with flash' do
        expect(subject).to redirect_to('/home')
        expect(req).to have_been_made
        expect(flash[:alert]).to eq(t('issue.message_threads.create.possible_spam'))
      end
    end

    context 'with a valid message' do
      let(:is_spam)  { 'false' }
      let(:approved) { true }

      it 'should redirect to thread with no flash' do
        expect(subject).to redirect_to("/threads/#{MessageThread.last.id}")
        expect(req).to have_been_made
        expect(flash[:alert]).to be_blank
      end
    end
  end
end
