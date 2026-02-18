class AddUseridToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :user_id, :integer
  end
end
