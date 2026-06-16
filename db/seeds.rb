require "faker"

User::SERIE_A_CLUBS.each do |club|
  rand(3..8).times do
    User.create!(
      name:     Faker::Name.name,
      email:    Faker::Internet.unique.email,
      password: "password123",
      age:      rand(18..55),
      club:     club
    )
  end
end

puts "✅ #{User.count} usuários fake criados!"

# Usuário de teste permanente (idempotente)
test_user_email = "pedropalermo97@gmail.com"
test_user = User.find_or_initialize_by(email: test_user_email)
test_user.name = "Pedro Palermo"
test_user.age = 30
test_user.club = "Flamengo"
# Define senha a cada seed para garantir acesso consistente em dev
test_user.password = "pedrop"
test_user.password_confirmation = "pedrop"
test_user.save!
puts "🔧 Usuário de teste garantido: #{test_user.email} (senha: pedrop)"
