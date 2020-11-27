require 'rails_helper'

describe "/home", type: :request do
  let(:user) { create(:user) }

  it 'should return "errors" => ["Para continuar, efetue login ou registre-se."] for requests without pass credentials' do
    get '/admin/v1/home'
    expect(json_body).to eq({ "errors" => ["Para continuar, efetue login ou registre-se."] })
  end

  it 'should have status 401: Unauthorized for requests without pass credentials' do
    get '/admin/v1/home'
    expect(response).to have_http_status(401)
  end

  it 'should return { "ok" => true } for successful gets requests' do
    get '/admin/v1/home', headers: auth_header(user)
    expect(json_body).to eq({ "ok" => true })
  end

  it 'should have status 200: ok for successful gets requests' do
    get '/admin/v1/home', headers: auth_header(user)
    expect(response).to have_http_status(200)
  end
end
