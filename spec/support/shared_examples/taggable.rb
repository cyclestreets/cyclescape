# frozen_string_literal: true

shared_examples "a taggable model" do
  it { is_expected.to have_and_belong_to_many(:tags) }

  context "tags string" do
    it "should set and return converting spaces to -" do
      subject.tags_string = "wheels pedals  bell"
      expect(subject.tags_string).to eq("wheels-pedals-bell")
    end

    context "tokenization" do
      it "should split on commas" do
        subject.tags_string = "one, two"
        expect(subject.tags.size).to eq(2)
        subject.tags_string = "three,four,five"
        expect(subject.tags.size).to eq(3)
      end

      it "should ignore double commas" do
        subject.tags_string = "six,,seven"
        expect(subject.tags.size).to eq(2)
      end

      it "should remove hash symbols" do
        subject.tags_string = "#one,#two"
        expect(subject.tags.size).to eq(2)
        expect(subject.tags[0].name).to eq("one")
        expect(subject.tags[1].name).to eq("two")
      end

      it "should remove exclamation marks" do
        subject.tags_string = "four!ed"
        expect(subject.tags.first.name).to eq("foured")
      end

      it "should remove parentheses" do
        subject.tags_string = "(one),two("
        expect(subject.tags.first.name).to eq("one")
        expect(subject.tags.second.name).to eq("two")
      end

      it "should remove square brackets" do
        subject.tags_string = "[one],two]"
        expect(subject.tags.first.name).to eq("one")
        expect(subject.tags.second.name).to eq("two")
      end

      it "should remove curly braces" do
        subject.tags_string = "{one},two{"
        expect(subject.tags.first.name).to eq("one")
        expect(subject.tags.second.name).to eq("two")
      end

      it "should ignore duplicates" do
        subject.tags_string = "one,one,one"
        expect(subject.tags.size).to eq(1)
      end

      it "should ignore invalid chars" do
        subject.tags_string = "one =,& two"
        expect(subject.tags.size).to eq(2)
      end
    end
  end
end
