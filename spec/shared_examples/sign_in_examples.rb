shared_examples 'sign in' do |email, password|
  let(:url) { '/auth/v1/user/sign_in' }

  context ':email and :password are right' do
    it 'should return user tokens on header' do
      post url, params: { email: email, password: password }
      sign_in_headers = %w[access-token token-type client expiry uid]
      expect(response.headers).to include(*sign_in_headers)
    end

    it 'should return success status' do
      post url, params: { email: email, password: password }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'invalid credentials' do
    it "shouldn't return token on header" do
      post url, params: { email: '', password: password }
      sign_in_headers = %w[access-token token-type client expiry uid]
      expect(response.headers).to_not include(*sign_in_headers)
    end

    it 'should return unauthenticated status' do
      post url, params: { email: email, password: '' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
