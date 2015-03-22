# == Schema Information
#
# Table name: library_documents
#
#  id              :integer          not null, primary key
#  library_item_id :integer          not null
#  title           :string(255)      not null
#  file_uid        :string(255)
#  file_name       :string(255)
#  file_size       :integer
#

require 'spec_helper'

describe Library::Document do
  it_behaves_like 'a library component'

  it 'should be valid' do
    doc = FactoryGirl.create(:library_document)
    expect(doc).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:notes) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'searchable text' do
    let(:doc) { FactoryGirl.create(:library_document) }
    it 'should have a searchable title' do
      expect(doc.searchable_text).to include doc.title
    end
  end

  context 'link with library item' do
    let(:attrs) { FactoryGirl.attributes_for(:library_document) }

    it 'should create a library item automatically' do
      doc = Library::Document.new(attrs, without_protection: true)
      expect(doc.save!).to be_truthy
      expect(doc.item).to be_truthy
    end

    it 'should create an item with reciprocal component links' do
      doc = Library::Document.new(attrs, without_protection: true)
      expect(doc.save!).to be_truthy
      expect(doc.item.component_type).to eq('Library::Document')
      expect(doc.item.component_id).to eq(doc.id)
      expect(Library::Item.find(doc.library_item_id).component).to eq(doc)
    end
  end
end
