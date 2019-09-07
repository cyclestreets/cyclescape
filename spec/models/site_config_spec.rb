# frozen_string_literal: true


require "spec_helper"

describe SiteConfig, type: :model do
  describe "#to_struct" do
    subject { build :site_config }

    it "has the dragonfly images" do
      subject.save!
      expect(subject.to_struct.logo).to start_with("/media/")
      expect(subject.to_struct.funder_image_footer6).to eq nil
    end

    it "has the attributes" do
      expect(subject.attributes.keys - subject.to_struct.to_h.keys.map(&:to_s)).to be_blank
    end
  end
end
