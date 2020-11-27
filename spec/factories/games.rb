FactoryBot.define do
  factory :game do
    mode { %i[pvp pve both].sample }
    release_date { "2020-11-21 10:34:23" }
    developer { Faker::Company.name }
    system_requirement
  end
end
