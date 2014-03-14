require 'spec_helper'

# Creating library items from messages
describe 'Library Messages' do
  context 'signed in' do
    include_context 'signed in as a site user'

    context 'plain messages' do
      let(:message) { FactoryGirl.create(:message) }

      it 'should create a library note from a message' do
        visit thread_path(message.thread)

        # Positive test for negative variants, below
        page.should have_content('Create')

        within '.message' do
          click_on I18n.t('.messages.message.create_note')
        end

        click_on 'Create Note'
        page.current_path.should == library_note_path(Library::Note.last)
        page.should have_content(message.body)
      end
    end

    context 'document messages' do
      let(:message) { FactoryGirl.create(:document_message) }

      it 'should create a library document from a document message' do
        visit thread_path(message.thread)

        # Positive test for negative variants, below
        page.should have_content('Create')

        within '.message' do
          click_on I18n.t('.messages.message.create_document')
        end

        click_on 'Add to Library'
        page.current_path.should == library_document_path(Library::Document.last)
        page.should have_content(message.title)
        page.should have_link('Download document')
      end

      it 'should fill show the right form' do
        visit thread_path(message.thread)
        within '.message' do
          click_on I18n.t('.messages.message.create_document')
        end

        page.should have_field('Title')
        page.should_not have_field('Document')
      end

      it 'should end up with the correct document' do
        visit thread_path(message.thread)
        within '.message' do
          click_on I18n.t('.messages.message.create_document')
        end

        click_on 'Add to Library'
        message.file.size.should eq(Library::Document.last.file.size)
      end
    end

    context 'photo messages' do
      let(:message) { FactoryGirl.create(:photo_message) }

      it 'should not let you create a library item' do
        visit thread_path(message.thread)

        page.should_not have_content 'Create'
      end
    end

    context 'deadline messages' do
      let(:message) { FactoryGirl.create(:deadline_message) }

      it 'should not let you create a library item' do
        visit thread_path(message.thread)

        page.should_not have_content 'Create'
      end
    end

    context 'url messages' do
      let(:message) { FactoryGirl.create(:link_message) }

      it 'should not let you create a library item' do
        visit thread_path(message.thread)

        page.should_not have_content 'Create'
      end
    end

    context 'library item messages' do
      let(:message) { FactoryGirl.create(:library_item_message_with_document) }

      it 'should not let the world implode' do
        message.message.save! # required for overly-complex reasons involving components-in-components
        visit thread_path(message.thread)

        page.should_not have_content 'Create'
      end
    end

    context 'security' do
      it "should not let you create a library note from a message you don't have access to"
    end
  end
end
