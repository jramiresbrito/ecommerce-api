json.coupon do
  json.call(@coupon, :id, :name, :code, :status, :discount_value, :max_use, :due_date)
end
