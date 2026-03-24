class CartItem::AddItemToCart
  include Interactor::Organizer

  organize CartItem::ValidateParams,
           CartItem::FindCart,
           CartItem::FindProduct,
           CartItem::ValidateStock,
           CartItem::UpsertCartItem,
           CartItem::TouchCart
end