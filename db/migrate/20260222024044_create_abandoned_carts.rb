class CreateAbandonedCarts < ActiveRecord::Migration[8.1]
  def change
    create_table :abandoned_carts do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :cart_total, precision: 10, scale: 2
      t.datetime :notified_at
      t.datetime :recovered_at
      t.integer :notification_count, default: 0
      t.string :status, default: 'pending' # pending, notified, recovered, expired

      t.timestamps
    end

    add_index :abandoned_carts, [:cart_id, :status]
    add_index :abandoned_carts, :notified_at
  end
end