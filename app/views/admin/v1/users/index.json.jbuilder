json.users do
  json.array! @loading_service.records, :id, :name, :email, :profile
end
