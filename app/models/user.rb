class User < ApplicationRecord
  has_secure_password
  has_one :cart, dependent: :destroy

  # Criar carrinho automaticamente após criar usuário
  after_create :create_user_cart

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true  
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  private

  def create_user_cart
    create_cart
  end
end