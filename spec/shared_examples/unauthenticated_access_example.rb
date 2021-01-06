shared_examples "unauthenticated access" do
  it "should return unauthorized - status code 401" do
    expect(response).to have_http_status(:unauthorized)
  end
end
