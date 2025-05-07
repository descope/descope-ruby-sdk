# frozen_string_literal: true


FactoryBot.define do
  factory :user, class: Hash do
    initialize_with { attributes }

    login_id { Faker::Internet.username }
    email { Faker::Internet.email }
    phone { "+1#{Faker::Number.number(digits: 10)}" }
    name { Faker::Name.name }
    given_name { Faker::Name.first_name }
    middle_name { "#{SpecUtils.build_prefix}Ruby-SDK-User" }
    family_name { Faker::Name.last_name }
  end
end
