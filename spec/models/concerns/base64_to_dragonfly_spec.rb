require 'spec_helper'

describe Base64ToDragonfly do
  let(:klass) do
    class Profile < ApplicationRecord
      self.table_name = "group_profiles"
      dragonfly_accessor :picture
      dragonfly_accessor :logo

      include Base64ToDragonfly
    end
  end
  subject { klass.new }

  it "defines dragonfly base64 read methods" do
    expect(subject.base64_logo).to eq nil
    expect(subject.base64_picture).to eq nil
  end

  it "defines dragonfly base64 write" do
    subject.base64_picture = "data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="
    expect(subject.picture.format).to eq "gif"
  end
end
