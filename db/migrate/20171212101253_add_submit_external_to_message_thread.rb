class AddSubmitExternalToMessageThread < ActiveRecord::Migration
  def change
    add_column :message_threads, :external_service_id, :integer
    create_table :external_services do |t|
      t.string :name, null: false
      t.string :short_name, null: false
    end
  end
end
