# == Schema Information
#
# Table name: library_notes
#
#  id                  :integer         not null, primary key
#  library_item_id     :integer         not null
#  title               :string(255)
#  body                :text            not null
#  library_document_id :integer
#

FactoryGirl.define do
  factory :library_note, class: 'Library::Note' do
    sequence(:title) { |n| "Library note #{n}" }
    body "Peter: I just bought a giant room full of gold coins that I'm going to dive into like Scrooge McDuck."
    created_by { FactoryGirl.create(:user) }

    trait :with_document do
      association :document, factory: :library_document
    end

    factory :library_note_with_document, traits: [:with_document]
  end
end
