class CartItem::UpsertCartItem
  include Interactor

  def call
    context.cart.with_lock do
      item = context.cart.cart_items.find_by(product_id: context.product_id)

      context.cart_item =
        if item
          item.tap { |i| i.update!(quantity: i.quantity + context.quantity.to_i) }
        else
          context.cart.cart_items.create!(
            product_id: context.product_id,
            quantity: context.quantity.to_i
          )
        end
    end
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: e.record.errors.full_messages.to_sentence)
  end
end
