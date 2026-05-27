class CreateCartHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total
      t.datetime :checkout_date
    end
  end
end
