require 'spec_helper'

describe Hashtag, type: :model do
  it ".extract_tag_names" do
    expect(described_class.extract_tag_names("#hash is a #hashtag but #1abc is not\n#hashtag2 is another #hashtag")).
      to contain_exactly("hash", "hashtag", "hashtag2")
  end
end
