require 'rails_helper'

RSpec.describe "Admin V1 Categories", type: :request do
  let(:user) { create(:user) }

  context "GET /categories" do
    let(:url) { "/admin/v1/categories" }
    # let! (ignores lazy loading) create instantly the variable.
    # Without it, RSpec wait the (url) invocation to create the variable.
    # I need it to be created before call the API.
    # With Lazy Loading the API would return an empty response.
    let!(:categories) { create_list(:category, 5) }
    before { get url, headers: auth_header(user) }

    it "returns all Categories" do
      # * (splat operator) does the array expansion. eg: [[1,2,3]] => [1,2,3]
      # read about it here https://www.freecodecamp.org/news/rubys-splat-and-double-splat-operators-ceb753329a78/
      expect(json_body['categories']).to contain_exactly(*categories.as_json(only: %i[id name]))
    end

    it "returns success status" do
      expect(response).to have_http_status(200)
    end
  end
end
