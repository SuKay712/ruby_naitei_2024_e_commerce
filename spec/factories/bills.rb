require "faker"
FactoryBot.define do
  factory :bill do
    user { create(:user) }
    phone_number { Faker::Base.regexify(/0\d{9}/) }
    note_content { Faker::Lorem.paragraph }
    voucher { create(:voucher) }
    status { Bill.statuses.keys.sample }
    address_attributes { attributes_for(:address) }
    bill_details do
      [
        build(:bill_detail, product: create(:product)),
        build(:bill_detail, product: create(:product)),
      ]
    end
    after(:build) do |bill|
      bill.calculate_subtotal
      bill.calculate_total_after_discount
    end
  end

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    activated { true }
    gender { User.genders.keys.sample }
    password { Faker::Internet.password(min_length: 9) }
    password_confirmation { password }
    activated_at { Time.zone.now }
  end

  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 100000..10000000) }
    remain_quantity { rand(1..100) }
    category { create(:category) }
    after(:create) do |product|
      product.image.attach(io: File.open(Rails.root.join('app/assets/images', 'prod1.jpg')), filename: 'prod1.jpg')
    end
  end


  factory :category do
    name { Faker::Commerce.department }
    parent_category_id { nil }

    after(:create) do |category|
      category.image.attach(io: File.open(Rails.root.join('app/assets/images', 'do-gia-dung.png')), filename: 'do-gia-dung.png')
    end
  end

  factory :voucher do
    name { Faker::Commerce.product_name }
    condition { rand(1000..5000) }
    discount { rand(0.05..0.2) }
    started_at { Time.zone.now }
    ended_at { started_at + 1.month }
  end

  factory :bill_detail do
    product { create(:product) }
    quantity { rand(1..5) }
  end

  factory :address do
    country { CS.countries.keys.sample }
    state { CS.states(country).keys.sample }
    city do
      cities = CS.cities(state, country)
      cities.present? ? cities.sample : nil
    end
    details { Faker::Address.street_address }
    bill
  end
end