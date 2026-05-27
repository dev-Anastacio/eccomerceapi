require "test_helper"

class ProductControllerTest < ActionDispatch::IntegrationTest
  setup do
    @password = "123456"
    @admin = User.create!(
      name: "Admin Product Tester",
      email: "admin_product_#{SecureRandom.hex(4)}@example.com",
      password: @password,
      password_confirmation: @password,
      role: :admin
    )
  end

  test "admin can create product with category and stock assigned to current user" do
    sign_in_as(@admin, @password)

    assert_difference "Product.count", 1 do
      post "/api/v1/products",
        params: {
          product: {
            name: "Produto API",
            description: "Criado pelo controller",
            price: 25.5,
            category: "Teste",
            stock: 7,
            user_id: users(:one).id
          }
        },
        headers: auth_headers,
        as: :json
    end

    assert_response :created
    product = Product.order(:id).last
    body = JSON.parse(response.body)

    assert_equal "Teste", product.category
    assert_equal 7, product.stock
    assert_equal @admin.id, product.user_id
    assert_equal @admin.id, body["user_id"]
  end

  private

  def sign_in_as(user, password)
    post "/api/v1/users/sign_in",
      params: { user: { email: user.email, password: password } }

    assert_response :ok
    @auth_token = response.headers["Authorization"]
    assert_match(/\ABearer /, @auth_token)
  end

  def auth_headers
    { "Authorization" => @auth_token }
  end
end
