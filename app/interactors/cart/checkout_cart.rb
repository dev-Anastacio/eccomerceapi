class Cart::CheckoutCart
  include Interactor::Organizer
  organize Cart::CheckoutCart::ValidateCheckout,
            Cart::CheckoutCart::ReserveInventory,
            Cart::CheckoutCart::CalculateTotals,
            Cart::CheckoutCart::CreateOrder,       
            Cart::CheckoutCart::ClearItems,
            Cart::CheckoutCart::RecordHistory
end