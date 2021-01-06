FactoryBot.define do
  factory :system_requirement do
    sequence(:name) { |n| "Basic #{n}" }
    operational_system { Faker::Computer.os }
    storage { '500gb' }
    processor { 'AMD Ryzen 7 3200x' }
    memory { '6gb' }
    video_board { 'NVidia GeForce 2080 TI' }
  end
end
