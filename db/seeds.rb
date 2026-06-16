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
