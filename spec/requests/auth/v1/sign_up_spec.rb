require 'rails_helper'

RSpec.describe 'Auth V1 Sign up', type: :request do
  let(:url) { '/auth/v1/user' }

  context 'valid params' do
    let(:user_params) { attributes_for(:user) }

    it 'should add a new user' do
      expect do
        post url, params: user_params
      end.to change(User, :count).by(1)
    end

    it 'should add a user as :client' do
      post url, params: user_params
      expect(User.last.profile).to eq 'client'
    end

    it 'should return success status' do
      post url, params: user_params
      expect(response).to have_http_status(:ok)
    end
  end
end
