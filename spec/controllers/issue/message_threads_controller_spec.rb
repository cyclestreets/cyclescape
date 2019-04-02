require 'spec_helper'
require 'issue/message_threads_controller'

describe Issue::MessageThreadsController, type: :controller do
  let(:approved)   { false }
  let(:user)       { create :user, approved: approved }
  let(:thread)     { create :message_thread, issue: issue }
  let(:issue)      { create :issue, created_by: user }
  let!(:message_a) { create(:message, thread: thread, created_at: Time.now - 4.days) }

  it 'has index' do
    get :index, params: { issue_id: thread.issue.id }
    expect(response.status).to eq(200)
  end

  describe 'creating' do
    let(:message) { attributes_for(:message) }
    before do
      warden.set_user user
    end

    let(:basic_body) do
      {
        blog: "http://www.cyclescape.org/",
        comment_author: user.full_name,
        comment_author_email: user.email,
        comment_content: message[:body],
        comment_type: "comment",
        is_test: "1"
      }
    end

    let!(:req) do
      stub_request(:post, %r{rest\.akismet\.com/1\.1/comment-check}).
        with(body: basic_body).to_return(status: 200, body: is_spam)
      stub_request(:post, %r{rest\.akismet\.com/1\.1/comment-check}).
        with(body: basic_body.merge(
          "HTTP_HOST" => "www.example.com",
          "HTTP_REFERER" => "http://www.example.com/users/sign_in",
          referrer: "http://www.example.com/users/sign_in",
          user_ip: "127.0.0.1"
        )).to_return(status: 200, body: is_spam)
    end
    subject { post :create, params: { issue_id: issue.id, thread: attributes_for(:message_thread), message: message } }

    context 'with an unapproved user' do
      let(:is_spam) { 'false' }

      it 'should redirect home with flash' do
        expect(subject).to redirect_to('/home')
        expect(flash[:alert]).to eq(t('not_approved'))
      end
    end

    context 'with an spam message' do
      let(:is_spam) { 'true' }

      it 'should redirect home with flash' do
        expect(subject).to redirect_to('/home')
        expect(flash[:alert]).to eq(t('possible_spam'))
      end

      it 'adds the message to the mod queue' do
        expect{subject}.to change{Message.mod_queued.count}.by(1)
      end

      it 'adds the thread to the mod queue' do
        expect{subject}.to change{MessageThread.mod_queued.count}.by(1)
      end
    end

    context 'with a valid message' do
      let(:is_spam)  { 'false' }
      let(:approved) { true }
      let(:last_thread) { MessageThread.last }

      it 'should redirect to thread with no flash' do
        expect(subject).to redirect_to("/threads/#{last_thread.id}")
        expect(flash[:alert]).to be_blank
      end

      it 'creates a approved thread and message' do
        subject
        message = last_thread.messages.last
        expect(last_thread.approved?).to eq true
        expect(message.approved?).to eq true
        expect(message.in_reply_to_id).to eq nil
      end
    end
  end
end
