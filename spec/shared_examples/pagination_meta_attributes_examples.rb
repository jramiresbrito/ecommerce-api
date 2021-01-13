shared_examples 'pagination meta attributes' do |pagination_attr|
  it 'should return :meta attributes with right pagination data' do
    pagination_attr.stringify_keys!
    expect(json_body['meta']).to include(pagination_attr)
  end
end
