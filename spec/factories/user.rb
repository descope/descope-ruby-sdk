# frozen_string_literal: true


FactoryBot.define do
  factory :user, class: Hash do
    initialize_with { attributes }

    login_id { Faker::Internet.username }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.cell_phone_with_country_code }
    display_name { Faker::Name.name }
    given_name { Faker::Name.first_name }
    middle_name { 'Ruby SDK User' }
    family_name { Faker::Name.last_name }
    picture { Faker::Internet.url }
  end
end
