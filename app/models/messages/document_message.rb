# frozen_string_literal: true


class DocumentMessage < MessageComponent
  dragonfly_accessor :file do
    storage_options :generate_file_path
  end

  validates :file, :title, presence: true

  protected

  def generate_file_path
    hash = Digest::SHA1.file(file.path).hexdigest
    { path: "message_documents/#{hash[0..2]}/#{hash[3..5]}/#{hash}" }
  end
end

# == Schema Information
#
# Table name: document_messages
#
#  id            :integer          not null, primary key
#  file_name     :string(255)
#  file_size     :integer
#  file_uid      :string(255)
#  title         :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#  created_by_id :integer          not null
#  message_id    :integer          not null
#  thread_id     :integer          not null
#
# Indexes
#
#  index_document_messages_on_created_by_id  (created_by_id)
#  index_document_messages_on_message_id     (message_id)
#  index_document_messages_on_thread_id      (thread_id)
#
