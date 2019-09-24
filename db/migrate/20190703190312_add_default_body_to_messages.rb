class AddDefaultBodyToMessages < ActiveRecord::Migration[5.0]
  def change
    change_column_default :messages, :body, ""
  end
end
