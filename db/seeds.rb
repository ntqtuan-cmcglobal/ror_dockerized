require 'faker'

500.times do
  ActiveRecord::Base.transaction do
    user = User.create!(
      full_name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      role: 'seller'
    )

    products = []
    10_000.times do
      products << {
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.sentence,
        price: Faker::Commerce.price(range: 1.0..1000.0),
        user_id: user.id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end
    Product.insert_all(products)
  end
end
