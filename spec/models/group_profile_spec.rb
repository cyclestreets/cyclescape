require 'spec_helper'

describe GroupProfile do
  describe 'to be valid' do
    subject { FactoryGirl.create(:group_profile) }

    it 'can have a blank description' do
      subject.description = nil
      expect(subject).to be_valid
    end

    it 'can have a blank location' do
      subject.location = nil
      expect(subject).to be_valid
    end

    it 'can have blank joining instructions' do
      subject.joining_instructions = nil
      expect(subject).to be_valid
    end

    it 'should accept a valid geojson string' do
      subject.location = nil
      subject.loc_json = '{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[0.14,52.27]}}'
      expect(subject).to be_valid
      expect(subject.location.x).to eql(0.14)
      expect(subject.location.y).to eql(52.27)
    end

    it 'should ignore a bogus geojson string' do
      subject.location = nil
      subject.loc_json = 'Garbage'
      expect(subject).to be_valid
      expect(subject.location).to be_nil
    end
  end
end
