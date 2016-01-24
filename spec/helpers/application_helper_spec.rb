require 'spec_helper'

describe ApplicationHelper, type: :helper do
  let(:thread)  { create :message_thread }
  let(:issue)   { create :issue, title: 'Important issue' }
  let(:message) { build(:message, body: body) }
  let(:body) { "This #{format} is useful" }

  include ApplicationHelper

  shared_examples 'links the thread' do
    it 'links the thread' do
      expect(message_linkify(message.body)).
        to eq "This <a href=\"/threads/#{thread.id}\">#{format}</a> is useful"
    end
  end

  shared_examples 'links the issue' do
    it 'links the thread' do
      expect(message_linkify(message.body)).
        to eq "This <a href=\"/issues/#{issue.id}-important-issue\">#{format}</a> is useful"
    end
  end

  describe 'message linkification' do
    context 'with #t format' do
      let(:format) { "#t#{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread :number format' do
      let(:format) { "thread #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread no :number format' do
      let(:format) { "thread no #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread no. :number format' do
      let(:format) { "thread no. #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread number :number format' do
      let(:format) { "thread no. #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread #:number format' do
      let(:format) { "thread ##{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with #i format' do
      let(:format) { "#i#{issue.id}" }
      include_examples 'links the issue'
    end

    context 'with #i with a mistake' do
      let(:format) { "#i0" }

      it 'does not link the issue' do
        expect(message_linkify(message.body)).to eq "This #i0 is useful"
      end
    end

    context 'with multiple formats' do
      let(:format) { "#i#{issue.id}, issue #{issue.id}, thread #{thread.id}, #i0" }

      it 'does not link the issue' do
        expect(message_linkify(message.body)).to eq(
          "This <a href=\"/issues/#{issue.id}-important-issue\">#i#{issue.id}</a>, <a href=\"/issues/#{issue.id}-important-issue\">issue #{issue.id}</a>, <a href=\"/threads/#{thread.id}\">thread #{thread.id}</a>, #i0 is useful"
        )
      end
    end

  end
end
