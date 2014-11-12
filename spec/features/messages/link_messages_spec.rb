require 'spec_helper'

describe 'Link messages' do
  let(:thread) { FactoryGirl.create(:message_thread) }

  def link_form
    within('#new-link-message') { yield }
  end

  context 'new', as: :site_user do
    let(:link_message_attrs) { FactoryGirl.attributes_for(:link_message) }

    before do
      visit thread_path(thread)
    end

    it 'should post a link message' do
      link_form do
        fill_in 'URL', with: link_message_attrs[:url]
        fill_in 'Title', with: link_message_attrs[:title]
        click_on 'Add Link'
      end
      page.should have_link(link_message_attrs[:title], href: link_message_attrs[:url])
    end

    it 'should accept a url with whitespace' do
      link_form do
        fill_in 'URL', with: "  #{link_message_attrs[:url]}  "
        fill_in 'Title', with: link_message_attrs[:title]
        click_on 'Add Link'
      end
      page.should have_link(link_message_attrs[:title], href: link_message_attrs[:url])
    end
  end

  context 'show' do
    let(:message) { FactoryGirl.create(:message, thread: thread) }
    let!(:link_message) { FactoryGirl.create(:link_message, message: message, created_by: FactoryGirl.create(:user)) }

    before do
      visit thread_path(thread)
    end

    it 'should display the link title and have correct URL' do
      page.should have_link(link_message.title, href: link_message.url)
    end

    it 'should display the message' do
      page.should have_content(message.body)
    end
  end
end
