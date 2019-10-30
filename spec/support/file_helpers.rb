# frozen_string_literal: true

def lorem_ipsum_path
  Rails.root.join("spec", "support", "text", "lorem.txt")
end

def abstract_image_path
  Rails.root.join("spec", "support", "images", "abstract-100-100.jpg")
end

def test_photo_path
  Rails.root.join("spec", "support", "images", "cycle-photo-1.jpg")
end

def profile_photo_path
  Rails.root.join("spec", "support", "images", "profile-image.jpg")
end

def pdf_document_path
  Rails.root.join("spec", "support", "documents", "use_cases.pdf")
end

def word_document_path
  Rails.root.join("spec", "support", "documents", "use_cases.doc")
end

def raw_email_path(type = "basic")
  Rails.root.join("spec", "support", "text", "#{type}_email.txt")
end
