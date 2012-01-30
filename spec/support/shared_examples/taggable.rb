shared_examples "a taggable model" do
  it { should have_and_belong_to_many(:tags) }

  context "tags string" do
    it "should set and return" do
      subject.tags_string = "wheels pedals bell"
      subject.tags_string.should == "wheels pedals bell"
    end

    context "tokenization" do
      it "should split on spaces" do
        subject.tags_string = "one two"
        subject.should have(2).tags
      end

      it "should split on commas" do
        subject.tags_string = "one, two"
        subject.should have(2).tags
        subject.tags_string = "three,four,five"
        subject.should have(3).tags
      end

      it "should ignore double commas" do
        subject.tags_string = "six,,seven"
        subject.should have(2).tags
      end

      it "should split on semi-colons" do
        subject.tags_string = "one;two;three"
        subject.should have(3).tags
      end

      it "should remove hash symbols" do
        subject.tags_string = "#one #two"
        subject.should have(2).tags
        subject.tags[0].name.should == "one"
        subject.tags[1].name.should == "two"
      end

      it "should remove exclamation marks" do
        subject.tags_string = "four!ed"
        subject.tags.first.name.should == "foured"
      end

      it "should remove parentheses" do
        subject.tags_string = "(one) two("
        subject.tags.first.name.should == "one"
        subject.tags.second.name.should == "two"
      end

      it "should remove square brackets" do
        subject.tags_string = "[one] two]"
        subject.tags.first.name.should == "one"
        subject.tags.second.name.should == "two"
      end

      it "should remove curly braces" do
        subject.tags_string = "{one} two{"
        subject.tags.first.name.should == "one"
        subject.tags.second.name.should == "two"
      end

      it "should ignore duplicates" do
        subject.tags_string = "one one one"
        subject.should have(1).tags
      end
    end
  end
end
