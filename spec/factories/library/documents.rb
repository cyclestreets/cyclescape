FactoryGirl.define do
  factory :library_document, class: "Library::Document" do
    item { FactoryGirl.build(:library_item) }
    sequence(:title) {|n| "Document #{n}" }
    file { Pathname.new(pdf_document_path) }

    after_build do |o|
      o.item.update_attributes(component: o)
    end

    factory :word_library_document do
      file { Pathname.new(word_document_path) }
    end
  end
end
