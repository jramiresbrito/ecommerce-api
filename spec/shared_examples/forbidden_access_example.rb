shared_examples "forbidden access" do
  it "should return an error message" do
    expect(json_body['errors']['message']).to eq "Forbidden access"
  end

  it "should return forbidden - status code 403" do
    expect(response).to have_http_status(:forbidden)
  end
end
