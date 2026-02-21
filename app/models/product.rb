class Product < ApplicationRecord
  has_many :cart_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 },allow_nil: true
end
