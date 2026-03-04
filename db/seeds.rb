# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Iniciando seed do banco de dados..."

# ─────────────────────────────────────────
# Limpa os dados existentes (ordem importa por causa das FK)
# ─────────────────────────────────────────
puts "🗑️  Limpando dados antigos..."
AbandonedCart.destroy_all
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all
User.destroy_all

# ─────────────────────────────────────────
# USUÁRIOS
# ─────────────────────────────────────────
puts "👤 Criando usuários..."

admin = User.create!(
  name: "Admin",
  email: "admin@email.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  address: "Rua do Admin, 1"
)

user1 = User.create!(
  name: "João Silva",
  email: "joao@email.com",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  address: "Rua das Flores, 100"
)

user2 = User.create!(
  name: "Maria Souza",
  email: "maria@email.com",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  address: "Av. Brasil, 250"
)

user3 = User.create!(
  name: "Carlos Lima",
  email: "carlos@email.com",
  password: "password123",
  password_confirmation: "password123",
  role: "user",
  address: "Rua das Palmeiras, 77"
)

puts "  ✅ #{User.count} usuários criados"

# ─────────────────────────────────────────
# PRODUTOS
# ─────────────────────────────────────────
puts "📦 Criando produtos..."

products_data = [
  { name: "Notebook Pro 15",    price: 4999.99, description: "Notebook com i7, 16GB RAM, 512GB SSD",           category: "Eletrônicos",   stock: 15, user_id: admin.id },
  { name: "Smartphone Galaxy",  price: 2499.90, description: "Smartphone 6.5\", 128GB, câmera 108MP",          category: "Eletrônicos",   stock: 30, user_id: admin.id },
  { name: "Fone Bluetooth",     price:  299.90, description: "Fone over-ear com cancelamento de ruído ativo",  category: "Eletrônicos",   stock: 50, user_id: admin.id },
  { name: "Teclado Mecânico",   price:  499.00, description: "Teclado gamer RGB, switch red",                  category: "Periféricos",   stock: 20, user_id: admin.id },
  { name: "Mouse Gamer",        price:  189.90, description: "Mouse óptico 16000 DPI, 7 botões",               category: "Periféricos",   stock: 40, user_id: admin.id },
  { name: "Monitor 27\"",       price: 1599.00, description: "Monitor IPS Full HD, 144Hz, 1ms",               category: "Periféricos",   stock: 10, user_id: admin.id },
  { name: "Cadeira Gamer",      price: 1299.00, description: "Cadeira ergonômica reclinável até 180°",         category: "Móveis",        stock:  8, user_id: admin.id },
  { name: "Mochila Notebook",   price:  199.90, description: "Mochila impermeável com porta USB, 30L",         category: "Acessórios",    stock: 25, user_id: admin.id },
  { name: "SSD 1TB",            price:  599.00, description: "SSD NVMe M.2, leitura 3500 MB/s",               category: "Armazenamento", stock: 35, user_id: admin.id },
  { name: "Webcam Full HD",     price:  249.90, description: "Webcam 1080p 30fps com microfone integrado",     category: "Periféricos",   stock: 18, user_id: admin.id }
]

products = products_data.map { |attrs| Product.create!(attrs) }

puts "  ✅ #{Product.count} produtos criados"

# ─────────────────────────────────────────
# ITENS NO CARRINHO (user1 - carrinho ativo com itens)
# ─────────────────────────────────────────
puts "🛒 Adicionando itens ao carrinho..."

cart1 = user1.cart
CartItem.create!(cart: cart1, product: products[0], quantity: 1)  # Notebook
CartItem.create!(cart: cart1, product: products[2], quantity: 2)  # Fone Bluetooth
CartItem.create!(cart: cart1, product: products[7], quantity: 1)  # Mochila

cart2 = user2.cart
CartItem.create!(cart: cart2, product: products[1], quantity: 1)  # Smartphone
CartItem.create!(cart: cart2, product: products[3], quantity: 1)  # Teclado Mecânico
CartItem.create!(cart: cart2, product: products[4], quantity: 1)  # Mouse Gamer

# user3 tem carrinho vazio (para testar endpoint de carrinho sem itens)
# admin não tem itens no carrinho

puts "  ✅ #{CartItem.count} itens de carrinho criados"

# ─────────────────────────────────────────
# CARRINHOS ABANDONADOS (para testar os jobs/e-mails)
# ─────────────────────────────────────────
puts "🛒💀 Criando carrinhos abandonados..."

# Pendente (recém-abandonado, ainda não notificado)
AbandonedCart.create!(
  cart: cart1,
  user: user1,
  cart_total: cart1.total,
  status: "pending",
  notification_count: 0,
  created_at: 2.hours.ago,
  updated_at: 2.hours.ago
)

# Notificado (já recebeu e-mail, pode receber lembrete)
abandoned2 = AbandonedCart.create!(
  cart: cart2,
  user: user2,
  cart_total: cart2.total,
  status: "notified",
  notification_count: 1,
  notified_at: 25.hours.ago,
  created_at: 3.days.ago,
  updated_at: 25.hours.ago
)

# Recuperado
cart3 = user3.cart
CartItem.create!(cart: cart3, product: products[5], quantity: 1) # Monitor
AbandonedCart.create!(
  cart: cart3,
  user: user3,
  cart_total: cart3.total,
  status: "recovered",
  notification_count: 2,
  notified_at: 5.days.ago,
  recovered_at: 1.day.ago,
  created_at: 7.days.ago,
  updated_at: 1.day.ago
)

puts "  ✅ #{AbandonedCart.count} carrinhos abandonados criados"

# ─────────────────────────────────────────
# RESUMO
# ─────────────────────────────────────────
puts ""
puts "═══════════════════════════════════════════"
puts "✅  Seed concluída com sucesso!"
puts "═══════════════════════════════════════════"
puts "👤 Usuários:             #{User.count}"
puts "📦 Produtos:             #{Product.count}"
puts "🛒 Itens de carrinho:    #{CartItem.count}"
puts "💀 Carrinhos abandonados:#{AbandonedCart.count}"
puts "═══════════════════════════════════════════"
puts ""
puts "🔑 Credenciais para login:"
puts "   Admin → admin@email.com    / password123"
puts "   User1 → joao@email.com     / password123"
puts "   User2 → maria@email.com    / password123"
puts "   User3 → carlos@email.com   / password123"
puts "═══════════════════════════════════════════"
