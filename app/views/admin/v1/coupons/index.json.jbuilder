json.coupons do
  json.array! @loading_service.records, :id, :name, :code, :status, :discount_value, :max_use, :due_date
end
