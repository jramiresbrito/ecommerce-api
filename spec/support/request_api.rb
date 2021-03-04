module RequestAPI
  def json_body(symbolize_keys: false)
    json = JSON.parse(response.body)
    symbolize_keys ? json.deep_symbolize_keys : json
  rescue StandardError
    return {}
  end

  def auth_header(user = nil, merge_with: {})
    user ||= create(:user)
    auth = user.create_new_auth_token
    header = auth.merge({ 'Content-type' => 'application/json', 'Accept' => 'application/json' })
    header.merge merge_with
  end

  def unauthenticated_header(merge_with: {})
    default_header = { 'Content-type' => 'application/json', 'Accept' => 'application/json' }
    default_header.merge merge_with
  end
end

RSpec.configure do |config|
  config.include RequestAPI, type: :request
end
