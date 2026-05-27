require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "stock must be an integer greater than or equal to zero" do
    product = Product.new(
      name: "Produto",
      description: "Produto para validar estoque",
      price: 10,
      stock: -1
    )

    assert_not product.valid?
    assert_includes product.errors[:stock], "must be greater than or equal to 0"
  end

  test "product can belong to a user" do
    product = products(:one)
    product.user = users(:one)

    assert product.valid?
    assert_equal users(:one), product.user
  end
end
