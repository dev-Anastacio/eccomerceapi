class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  has_one :cart, dependent: :destroy
  has_many :abandoned_carts, dependent: :destroy

  # Criar carrinho automaticamente após criar usuário
  after_create :create_user_cart

  validates :name, presence: true

  enum :role, { user: "user", admin: "admin" }, default: :user

  def can_manage_products?
    admin?
  end

  private

  def create_user_cart
    create_cart
  end
end
