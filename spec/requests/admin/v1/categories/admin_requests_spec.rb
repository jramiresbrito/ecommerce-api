require 'rails_helper'

RSpec.describe 'Admin V1 Categories as :admin', type: :request do
  let(:user) { create(:user) }

  context 'GET /categories' do
    let(:url) { '/admin/v1/categories' }
    # let! (ignores lazy loading) create instantly the variable.
    # Without it, RSpec wait the (url) invocation to create the variable.
    # I need it to be created before call the API.
    # With Lazy Loading the API would return an empty response.
    let!(:categories) { create_list(:category, 10) }

    context 'without any params' do
      it 'should return 10 Categories' do
        get url, headers: auth_header(user)
        expect(json_body['categories'].count).to eq 10
      end

      it 'should return 10 first Categories' do
        get url, headers: auth_header(user)
        expected_categories = categories[0..9].as_json(only: %i[id name])
        expect(json_body['categories']).to contain_exactly(*expected_categories)
      end

      it 'should return success status' do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with search[name] param' do
      let!(:search_name_categories) do
        categories = []
        15.times { |n| categories << create(:category, name: "Search #{n + 1}") }
        categories
      end

      let(:search_params) { { search: { name: 'Search' } } }

      it 'should return only searched categories limited by default pagination' do
        get url, headers: auth_header(user), params: search_params
        expected_categories = search_name_categories[0..9].map do |category|
          category.as_json(only: %i[id name])
        end
        expect(json_body['categories']).to contain_exactly(*expected_categories)
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

      it 'returns records sized by :length' do
        get url, headers: auth_header(user), params: pagination_params
        expect(json_body['categories'].count).to eq length
      end

      it 'returns categories limited by pagination' do
        get url, headers: auth_header(user), params: pagination_params
        expected_categories = categories[5..9].as_json(only: %i[id name])
        expect(json_body['categories']).to contain_exactly(*expected_categories)
      end

      it 'returns success status' do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with order params' do
      let(:order_params) { { order: { name: 'desc' } } }

      it 'returns ordered categories limited by default pagination' do
        get url, headers: auth_header(user), params: order_params
        categories.sort! { |a, b| b[:name] <=> a[:name] }
        expected_categories = categories[0..9].as_json(only: %i[id name])
        expect(json_body['categories']).to contain_exactly(*expected_categories)
      end

      it 'returns success status' do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'POST /categories' do
    let(:url) { '/admin/v1/categories' }

    context 'valid params' do
      let(:category_params) { { category: attributes_for(:category) }.to_json }

      it 'should add a new category' do
        expect do
          # I can't put this in the "before" because I want to use the change method
          # I needs to be inside the block :'(
          post url, headers: auth_header(user), params: category_params
        end.to change(Category, :count).by(1)
      end

      it 'should return the last added category' do
        post url, headers: auth_header(user), params: category_params
        expected_category = Category.last.as_json(only: %i[id name])
        expect(json_body['category']).to eq expected_category
      end

      it 'should return success status' do
        post url, headers: auth_header(user), params: category_params
        expect(response).to have_http_status(:ok) # status code 200
      end
    end

    context 'invalid params' do
      let(:category_invalid_params) do
        { category: attributes_for(:category, name: nil) }.to_json
      end

      it "shouldn't add a new Category" do
        expect do
          post url, headers: auth_header(user), params: category_invalid_params
        end.to_not change(Category, :count)
      end

      it 'should return error messages' do
        post url, headers: auth_header(user), params: category_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity - status code 422' do
        post url, headers: auth_header(user), params: category_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'PATCH /categories/:id' do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    context 'valid params' do
      let(:new_name) { 'My new Category' }
      let(:category_params) { { category: { name: new_name } }.to_json }

      it 'should update a category' do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expect(category.name).to eq new_name
      end

      it 'should return the updated category' do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expected_category = category.as_json(only: %i[id name])
        expect(json_body['category']).to eq expected_category
      end

      it 'should return success status' do
        patch url, headers: auth_header(user), params: category_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'invalid params' do
      let(:category_invalid_params) do
        { category: attributes_for(:category, name: nil) }.to_json
      end

      it "shouldn't update a category" do
        old_name = category.name
        patch url, headers: auth_header(user), params: category_invalid_params
        category.reload
        expect(category.name).to eq old_name
      end

      it 'should return error messages' do
        patch url, headers: auth_header(user), params: category_invalid_params
        expect(json_body['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable_entity - status code 422' do
        patch url, headers: auth_header(user), params: category_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'DELETE /categories/:id' do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    it 'should remove a category' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Category, :count).by(-1)
    end

    it 'should return success - status code 204' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "shouldn't return any body content" do
      delete url, headers: auth_header(user)
      expect(json_body).to_not be_present
    end

    it 'should remove all associated product categories' do
      product_categories = create_list(:product_category, 3, category: category)
      delete url, headers: auth_header(user)
      expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))
      expect(expected_product_categories).to eq []
    end
  end
end
