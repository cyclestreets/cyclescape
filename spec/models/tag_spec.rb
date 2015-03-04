# == Schema Information
#
# Table name: tags
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#  icon :string(255)
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#

require 'spec_helper'

describe Tag do
  it { is_expected.to validate_presence_of(:name) }

  it 'should set and return a name' do
    subject.name = 'test'
    expect(subject.name).to eq('test')
  end

  it 'should lowercase the name' do
    subject.name = 'TeStINg'
    expect(subject.name).to eq('testing')
  end

  context 'names' do
    let(:tags) { 4.times.map { Tag.create(name: FactoryGirl.generate(:tag)) } }

    it 'should return the tag names as an array' do
      tags
      expect(Tag.names).to eq(tags.map { |tag| tag.name })
    end
  end

  context 'grab' do
    it 'should return a tag with the correct name' do
      expect(Tag.grab('spokes').name).to eq('spokes')
    end

    it "should return a created Tag if it doesn't exist" do
      expect(Tag.grab('wheels')).not_to be_new_record
    end

    it 'should return an existing tag if present' do
      existing = Tag.create(name: 'pedals')
      found = Tag.grab('pedals')
      expect(found).to eq(existing)
    end

    it 'should still make the tag lowercase' do
      expect(Tag.grab('cHAiN').name).to eq('chain')
    end

    it 'should find the tag if given mixed case' do
      existing = Tag.create(name: 'reflectors')
      found = Tag.grab('Reflectors')
      expect(found).to eq(existing)
    end
  end
end
