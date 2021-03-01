if Rails.env.development? || Rails.env.test?
  require 'factory_bot'

  # rubocop:disable Metrics/BlockLength
  namespace :dev do
    desc 'Sample data for local development environment'
    task prime: 'db:setup' do
      include FactoryBot::Syntax::Methods

      puts "Creating Users..."
      15.times do
        profile = %i[admin client].sample
        create(:user, profile: profile)
      end
      puts "Users Created!"

      puts "Creating Sytem Requirements..."
      system_requirements = []
      %w[Basic Intermediate Advanced].each do |sr_name|
        system_requirements << create(:system_requirement, name: sr_name)
      end
      puts "System Requirements Created!"

      puts "Creating Coupons..."
      15.times do
        coupon_status = %i[active inactive].sample
        create(:coupon, status: coupon_status)
      end
      puts "Coupons Created!"

      puts "Creating Categories..."
      categories = []
      25.times do
        categories << create(:category, name: Faker::Game.unique.genre)
      end
      puts "Categories Created!"

      puts "Creating Games..."
      30.times do
        game_name = Faker::Game.unique.title
        availability = %i[available unavailable].sample
        categories_count = rand(0..3)
        game_categories_ids = []
        featured = [true, false].sample
        release_date = (0..15).to_a.sample.days.ago
        categories_count.times { game_categories_ids << Category.all.sample.id }
        game = create(:game, system_requirement: system_requirements.sample, release_date: release_date)
        create(:product, name: game_name, status: availability,
                         featured: featured, category_ids: game_categories_ids, productable: game)
      end
      puts "Games Created!"

      puts "Creating Licenses..."
      50.times do
        game = Game.all[0...5].sample
        status = %i[available in_use inactive].sample
        platform = %i[steam battle_net origin].sample
        create(:license, status: status, platform: platform, game: game)
      end
      puts "Licenses Created!"
      puts "Done."
    end
  end
  # rubocop:enable Metrics/BlockLength
end
