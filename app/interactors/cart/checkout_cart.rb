class Cart::CheckoutCart
  include Interactor::Organizer

  organize Cart::CheckoutCart::ValidateCheckout,
            Cart::CheckoutCart::ReserveInventory,
            Cart::CheckoutCart::CalculateTotals,
            Cart::CheckoutCart::CreateOrder,
            Cart::CheckoutCart::ClearItems,
            Cart::CheckoutCart::RecordHistory

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
      raise ActiveRecord::Rollback if context.failure?
    end
  end
end
