shared_examples "a taggable model" do
  it { should have_and_belong_to_many(:tags) }

  context "tags string" do
    it "should set and return" do
      subject.tags_string = "wheels pedals bell"
      subject.tags_string.should == "wheels pedals bell"
    end
  end
end
