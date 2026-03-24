class CartHistory < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :checkout_date, presence: true
end
