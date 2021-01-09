require 'rails_helper'

RSpec.describe 'Admin V1 Products as :admin', type: :request do
  let(:user) { create(:user) }

  context 'GET /products' do
    let(:url) { '/admin/v1/products' }
    let!(:categories) { create_list(:category, 2) }
    let!(:products) { create_list(:product, 10, categories: categories) }

    context 'without any params' do
      it 'should return 10 records' do
        get url, headers: auth_header(user)
        expect(json_body['products'].count).to eq 10
      end

      it 'should return Products with :productable following default pagination' do
        get url, headers: auth_header(user)
        expected_return = products[0..9].map do |product|
          build_game_product_json(product)
        end
        expect(json_body['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with search[name] param' do
      let!(:search_name_products) do
        products = []
        15.times { |n| products << create(:product, name: "Search #{n + 1}") }
        products
      end

      let(:search_params) { { search: { name: 'Search' } } }

      it 'should return only seached products limited by default pagination' do
        get url, headers: auth_header(user), params: search_params
        expected_return = search_name_products[0..9].map do |product|
          build_game_product_json(product)
        end
        expect(json_body['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        get url, headers: auth_header(user), params: search_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with pagination params' do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it 'should return records sized by :length' do
        get url, headers: auth_header(user), params: pagination_params
        expect(json_body['products'].count).to eq length
      end

      it 'should return products limited by pagination' do
        get url, headers: auth_header(user), params: pagination_params
        expected_return = products[5..9].map do |product|
          build_game_product_json(product)
        end
        expect(json_body['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with order params' do
      let(:order_params) { { order: { name: 'desc' } } }

      it 'should return ordered products limited by default pagination' do
        get url, headers: auth_header(user), params: order_params
        products.sort! { |a, b| b[:name] <=> a[:name] }
        expected_return = products[0..9].map do |product|
          build_game_product_json(product)
        end
        expect(json_body['products']).to contain_exactly(*expected_return)
      end

      it 'should return success status' do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'GET /products/:id' do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it 'should return requested Product' do
      get url, headers: auth_header(user)
      expected_product = build_game_product_json(product)
      expect(json_body['product']).to eq expected_product
    end

    it 'should return success status' do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context 'POST /products' do
    let(:url) { '/admin/v1/products' }
    let(:categories) { create_list(:category, 2) }
    let(:system_requirement) { create(:system_requirement) }
    let(:post_header) { auth_header(user, merge_with: { 'Content-Type' => 'multipart/form-data' }) }

    context 'with valid params' do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_params) do
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id))
                                           .merge(productable: 'game').merge(game_params) }
      end

      it 'should add a new Product' do
        expect do
          post url, headers: post_header, params: product_params
        end.to change(Product, :count).by(1)
      end

      it 'should add a new productable' do
        expect do
          post url, headers: post_header, params: product_params
        end.to change(Game, :count).by(1)
      end

      it 'should associate categories to Product' do
        post url, headers: post_header, params: product_params
        expect(Product.last.categories.ids).to contain_exactly(*categories.map(&:id))
      end

      it 'should return the last added Product' do
        post url, headers: post_header, params: product_params
        expected_product = build_game_product_json(Product.last)
        expect(json_body['product']).to eq expected_product
      end

      it 'should return success status' do
        post url, headers: post_header, params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid Product params' do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil).merge(category_ids: categories.map(&:id))
                                                      .merge(productable: 'game').merge(game_params) }
      end

      it "shouldn't add a new Product" do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.to_not change(Product, :count)
      end

      it "shouldn't add a new productable" do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.to_not change(Game, :count)
      end

      it "shouldn't create ProductCategory" do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.to_not change(ProductCategory, :count)
      end

      it 'should return an error message' do
        post url, headers: post_header, params: product_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity status' do
        post url, headers: post_header, params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid :productable params' do
      let(:game_params) { attributes_for(:game, developer: '', system_requirement_id: system_requirement.id) }
      let(:invalid_productable_params) do
        { product: attributes_for(:product).merge(productable: 'game').merge(game_params) }
      end

      it "shouldn't add a new Product" do
        expect do
          post url, headers: post_header, params: invalid_productable_params
        end.to_not change(Product, :count)
      end

      it "shouldn't add a new productable" do
        expect do
          post url, headers: post_header, params: invalid_productable_params
        end.to_not change(Game, :count)
      end

      it "shouldn't create ProductCategory" do
        expect do
          post url, headers: post_header, params: invalid_productable_params
        end.to_not change(ProductCategory, :count)
      end

      it 'should return an error message' do
        post url, headers: post_header, params: invalid_productable_params
        expect(json_body['errors']['fields']).to have_key('developer')
      end

      it 'should return unprocessable_entity status' do
        post url, headers: post_header, params: invalid_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without :productable params' do
      let(:product_without_productable_params) do
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id)) }
      end

      it "shouldn't add a new Product" do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.to_not change(Product, :count)
      end

      it "shouldn't add a new productable" do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.to_not change(Game, :count)
      end

      it "shouldn't create ProductCategory" do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.to_not change(ProductCategory, :count)
      end

      it 'should return an error message' do
        post url, headers: post_header, params: product_without_productable_params
        expect(json_body['errors']['fields']).to have_key('productable')
      end

      it 'should return unprocessable_entity status' do
        post url, headers: post_header, params: product_without_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'PATCH /products/:id' do
    let(:old_categories) { create_list(:category, 2) }
    let(:new_categories) { create_list(:category, 2) }
    let(:product) { create(:product, categories: old_categories) }
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/products/#{product.id}" }
    let(:patch_header) { auth_header(user, merge_with: { 'Content-Type' => 'multipart/form-data' }) }

    context 'with valid Product params' do
      let(:new_name) { 'New name' }
      let(:product_params) do
        { product: attributes_for(:product, name: new_name).merge(category_ids: new_categories.map(&:id)) }
      end

      it 'should update Product' do
        patch url, headers: patch_header, params: product_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'should update to new categories' do
        patch url, headers: patch_header, params: product_params
        product.reload
        expect(product.categories.ids).to contain_exactly(*new_categories.map(&:id))
      end

      it 'should return the updated Product' do
        patch url, headers: patch_header, params: product_params
        product.reload
        expected_product = build_game_product_json(product)
        expect(json_body['product']).to eq expected_product
      end

      it 'should return success status' do
        patch url, headers: patch_header, params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid Product params' do
      let(:product_invalid_params) do
        { product: attributes_for(:product, name: nil).merge(category_ids: new_categories.map(&:id)) }
      end

      it "shouldn't update Product" do
        old_name = product.name
        patch url, headers: patch_header, params: product_invalid_params
        product.reload
        expect(product.name).to eq old_name
      end

      it 'should keep the old categories' do
        patch url, headers: patch_header, params: product_invalid_params
        product.reload
        expect(product.categories.ids).to contain_exactly(*old_categories.map(&:id))
      end

      it 'should return an error message' do
        patch url, headers: patch_header, params: product_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity status' do
        patch url, headers: patch_header, params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid :productable params' do
      let(:invalid_productable_params) do
        { product: attributes_for(:game, developer: '') }
      end

      it "shouldn't update productable" do
        old_developer = product.productable.developer
        patch url, headers: patch_header, params: invalid_productable_params
        product.productable.reload
        expect(product.productable.developer).to eq old_developer
      end

      it 'should return an error message' do
        patch url, headers: patch_header, params: invalid_productable_params
        expect(json_body['errors']['fields']).to have_key('developer')
      end

      it 'should return unprocessable_entity status' do
        patch url, headers: patch_header, params: invalid_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without :productable params' do
      let(:new_name) { 'New name' }
      let(:product_without_productable_params) do
        { product: attributes_for(:product, name: new_name).merge(category_ids: new_categories.map(&:id)) }
      end

      it 'should update Product' do
        patch url, headers: patch_header, params: product_without_productable_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'should update to new categories' do
        patch url, headers: patch_header, params: product_without_productable_params
        product.reload
        expect(product.categories.ids).to contain_exactly(*new_categories.map(&:id))
      end

      it 'should return the updated Product' do
        patch url, headers: patch_header, params: product_without_productable_params
        product.reload
        expected_product = build_game_product_json(product)
        expect(json_body['product']).to eq expected_product
      end

      it 'should return success status' do
        patch url, headers: patch_header, params: product_without_productable_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'DELETE /products/:id' do
    let(:productable) { create(:game) }
    let!(:product) { create(:product, productable: productable) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it 'should remove the Product' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Product, :count).by(-1)
    end

    it 'should remove productable' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Game, :count).by(-1)
    end

    it 'should return success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "shouldn't return any body content" do
      delete url, headers: auth_header(user)
      expect(json_body).to_not be_present
    end

    it 'should remove all associated product categories' do
      product_categories = create_list(:product_category, 3, product: product)
      delete url, headers: auth_header(user)
      expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))
      expect(expected_product_categories.count).to eq 0
    end

    it "shouldn't remove unassociated product categories" do
      product_categories = create_list(:product_category, 3)
      delete url, headers: auth_header(user)
      present_product_categories_ids = product_categories.map(&:id)
      expected_product_categories = ProductCategory.where(id: present_product_categories_ids)
      expect(expected_product_categories.ids).to contain_exactly(*present_product_categories_ids)
    end
  end
end

def build_game_product_json(product)
  json = product.as_json(only: %i[id name description price status])
  json['image_url'] = rails_blob_url(product.image)
  json['productable'] = product.productable_type.underscore
  json['categories'] = product.categories.as_json
  json.merge! product.productable.as_json(only: %i[mode release_date developer])
  json['system_requirement'] = product.productable.system_requirement.as_json
  json
end
