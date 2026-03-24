require "test_helper"

class CheckoutFlowTest < ActionDispatch::IntegrationTest
  setup do
    @password = "123456"
    @user = User.create!(
      name: "Checkout Tester",
      email: "checkout_#{SecureRandom.hex(4)}@example.com",
      password: @password,
      password_confirmation: @password,
      role: :user
    )
    @cart = @user.cart || @user.create_cart
  end

  test "checkout succeeds and creates order" do
    product = Product.create!(
      name: "Produto Checkout",
      description: "Produto para teste de checkout",
      price: 100.0,
      stock: 5,
      category: "Teste"
    )

    sign_in_as(@user, @password)

    post "/api/v1/cart_items",
      params: { cart_item: { product_id: product.id, quantity: 2 } },
      as: :json

    assert_response :created

    assert_difference ["Order.count", "OrderItem.count", "CartHistory.count"], 1 do
      post "/api/v1/users/#{@user.id}/cart/checkout"
    end

    assert_response :created

    body = JSON.parse(response.body)
    assert_equal "Checkout realizado com sucesso", body["message"]
    assert_equal "pending", body["status"]

    assert_equal 0, @cart.reload.cart_items.count
    assert_equal 3, product.reload.stock
  end

  test "checkout fails when cart is empty" do
    sign_in_as(@user, @password)

    assert_no_difference ["Order.count", "OrderItem.count", "CartHistory.count"] do
      post "/api/v1/users/#{@user.id}/cart/checkout"
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["error"], "carrinho está vazio"
  end

  test "checkout fails when item quantity is above stock" do
    product = Product.create!(
      name: "Produto Sem Estoque",
      description: "Produto para validar estoque",
      price: 50.0,
      stock: 1,
      category: "Teste"
    )

    # Bypass add-to-cart interactor guard to assert checkout stock validation.
    @cart.cart_items.create!(product: product, quantity: 3)

    sign_in_as(@user, @password)

    assert_no_difference ["Order.count", "OrderItem.count", "CartHistory.count"] do
      post "/api/v1/users/#{@user.id}/cart/checkout"
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["error"], "não tem estoque suficiente"
    assert_equal 1, product.reload.stock
  end

  private

  def sign_in_as(user, password)
    post "/api/v1/users/sign_in",
      params: { user: { email: user.email, password: password } }

    assert_includes [200, 302, 303], response.status
  end
end
