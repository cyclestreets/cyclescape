# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  picture_uid :string(255)
#  website     :string(255)
#  about       :text
#
# Indexes
#
#  index_user_profiles_on_user_id  (user_id)
#

require 'spec_helper'

describe UserProfile do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end
  it do
    is_expected.to validate_inclusion_of(:visibility).
      in_array(%w(public group))
  end

  context 'picture' do
    subject { FactoryGirl.create(:user_profile) }

    it 'should accept and save a picture' do
      expect(subject.picture_uid).not_to be_blank
      expect(subject.picture.mime_type).to eq('image/jpeg')
    end

    it 'should provide a thumbnail of the picture' do
      expect(subject.picture_thumbnail).to be_truthy
      expect(subject.picture_thumbnail.width).to eq(50)
      expect(subject.picture_thumbnail.height).to eq(50)
    end

    it 'should not accept a text document for a picture' do
      expect(subject).to have(0).errors_on(:picture)
      subject.picture = File.open(lorem_ipsum_path)
      expect(subject).to have(1).error_on(:picture)
    end
  end

  context 'url' do
    subject { FactoryGirl.create(:user_profile) }

    it 'should allow a valid URL with HTTP protocol' do
      subject.website = 'http://en.wikipedia.org/wiki/Family_Guy'
      expect(subject).to have(0).errors_on(:website)
    end

    it 'should allow a valid URL with HTTPS protocol' do
      subject.website = 'https://en.wikipedia.org/wiki/Family_Guy'
      expect(subject).to have(0).errors_on(:website)
    end

    it 'should allow a valid URL without protocol' do
      subject.website = 'en.wikipedia.org/wiki/Family_Guy'
      expect(subject).to have(0).errors_on(:website)
    end

    it 'should prefix the HTTP protocol on a URL without protocol' do
      subject.website = 'en.wikipedia.org/wiki/Family_Guy'
      expect(subject.website).to eq('http://en.wikipedia.org/wiki/Family_Guy')
    end

    it 'should not allow a URL with FTP protocol' do
      subject.website = 'ftp://en.wikipedia.org/wiki/Family_Guy'
      expect(subject).to have(1).error_on(:website)
    end

    it 'should not allow an invalid URL' do
      subject.website = 'w[iki]pedia.org/wiki/Family_Guy'
      expect(subject).to have(1).error_on(:website)
    end

    it 'should accept a blank url' do
      subject.website = ''
      expect(subject.website).to be === ''
      expect(subject).to have(0).errors_on(:website)
    end
  end

  context 'clearing' do
    subject { FactoryGirl.create(:user_profile) }

    it 'should remove the website' do
      expect(subject.website).not_to be_nil
      subject.clear
      subject.reload # check it was saved
      expect(subject.website).to be_nil
    end

    it 'should remove the about text' do
      expect(subject.about).not_to be_nil
      subject.clear
      subject.reload
      expect(subject.about).to be_nil
    end

    it 'should remove the picture' do
      expect(subject.picture).not_to be_nil
      subject.clear
      subject.reload
      expect(subject.picture).to be_nil
    end
  end
end
