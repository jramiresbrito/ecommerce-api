class Coupon < ApplicationRecord
  include Paginatable

  validates :name, :code, :status, :due_date, :discount_value, presence: true
  validates :code, uniqueness: { case_sensitive: false }
  validates :discount_value, numericality: { greater_than: 0 }
  validates :max_use, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :due_date, future_date: true

  enum status: { active: 1, inactive: 2 }
end
