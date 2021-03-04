require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe "Storefront V1 Home", type: :request do
  context "GET /home" do
    let(:url) { "/storefront/v1/home" }

    let!(:featured_products) { create_list(:product, 10, featured: true) }

    let!(:cheap_products) do
      products = []
      10.times do
        products << create(:product, price: Faker::Commerce.price(range: 5.00...90.00), featured: false)
      end
      products
    end

    let!(:last_released_products) do
      products = []
      10.times do
        game = create(:game, release_date: 7.days.ago)
        products << create(:product, productable: game, featured: false)
      end
      products
    end

    context "on :featured" do
      it "returns 4 products" do
        get url, headers: unauthenticated_header
        expect(json_body['featured'].count).to eq 4
      end

      it "returns random featured products" do
        get url, headers: unauthenticated_header
        expected_products = featured_products.map { |product| build_game_product_json(product) }
        expect(json_body['featured']).to satisfy do |products|
          products & expected_products == products
        end
      end

      it "does not returns any non-featured products" do
        get url, headers: unauthenticated_header
        unexpected_products = (last_released_products + cheap_products).map do |product|
          build_game_product_json(product)
        end
        expect(json_body['featured']).to_not include(*unexpected_products)
      end
    end

    context "on :last_releases" do
      it "returns 4 products" do
        get url, headers: unauthenticated_header
        expect(json_body['last_releases'].count).to eq 4
      end

      it "returns random last released products" do
        get url, headers: unauthenticated_header
        expected_products = last_released_products.map do |product|
          build_game_product_json(product)
        end
        expect(json_body['last_releases']).to satisfy do |products|
          products & expected_products == products
        end
      end

      it "does not returns any non-last released products" do
        get url, headers: unauthenticated_header
        unexpected_products = (featured_products + cheap_products).map do |product|
          build_game_product_json(product)
        end
        expect(json_body['last_releases']).to_not include(*unexpected_products)
      end
    end

    context "on :cheapest" do
      it "returns 4 products" do
        get url, headers: unauthenticated_header
        expect(json_body['cheapest'].count).to eq 4
      end

      it "returns cheapest products" do
        get url, headers: unauthenticated_header
        price_ordered_products = cheap_products.sort { |a, b| a.price <=> b.price }
        expected_products = price_ordered_products.map { |product| build_game_product_json(product) }
        expect(json_body['cheapest']).to contain_exactly(*expected_products.take(4))
      end

      it "does not returns any non-last released products" do
        get url, headers: unauthenticated_header
        unexpected_products = (featured_products + last_released_products).map do |product|
          build_game_product_json(product)
        end
        expect(json_body['cheapest']).to_not include(*unexpected_products)
      end
    end
  end

  def build_game_product_json(product)
    json = product.as_json(only: %i[id name description])
    json['price'] = product.price.to_f
    json['image_url'] = rails_blob_url(product.image)
    json
  end
end
# rubocop:enable Metrics/BlockLength
