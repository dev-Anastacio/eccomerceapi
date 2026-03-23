class AddItemToCart
  include Interactor::Organizer

  organize AddItemToCart::ValidateParams,
           AddItemToCart::FindCart,
           AddItemToCart::FindProduct,
           AddItemToCart::ValidateStock,
           AddItemToCart::UpsertCartItem,
           AddItemToCart::TouchCart
end