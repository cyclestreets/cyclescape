class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :thread_subscriptions, [:thread_id, :user_id]
    remove_index :user_thread_priorities, :thread_id
    remove_index :user_thread_priorities, :user_id
    add_index :user_thread_priorities, [:thread_id, :user_id]
    add_index :site_comments, :user_id
    add_index :street_view_messages, :created_by_id
    add_index :photo_messages, :message_id
    add_index :photo_messages, :thread_id
    add_index :photo_messages, :created_by_id
    add_index :link_messages, :message_id
    add_index :link_messages, :thread_id
    add_index :link_messages, :created_by_id
    add_index :library_item_messages, :message_id
    add_index :library_item_messages, :thread_id
    add_index :library_item_messages, :created_by_id
    add_index :library_item_messages, :library_item_id
    add_index :library_item_messages, [:library_item_id, :thread_id]
    add_index :document_messages, :message_id
    add_index :document_messages, :thread_id
    add_index :document_messages, :created_by_id
    add_index :deadline_messages, :message_id
    add_index :deadline_messages, :thread_id
    add_index :deadline_messages, :created_by_id
    add_index :library_notes, :library_item_id
    add_index :library_notes, :library_document_id
    add_index :library_documents, :library_item_id
    add_index :messages, [:component_id, :component_type]
    add_index :group_requests, :actioned_by_id
    add_index :group_prefs, :membership_secretary_id
    add_index :user_locations, :category_id
    add_index :library_items, [:component_id, :component_type]
    add_index :library_items, :created_by_id
    add_index :users, :remembered_group_id
    add_index :group_membership_requests, :actioned_by_id
    add_index :planning_applications, :location, using: :gist
  end
end
