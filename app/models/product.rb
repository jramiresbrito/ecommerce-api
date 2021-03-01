class Product < ApplicationRecord
  include LikeSearchable
  include Paginatable

  belongs_to :productable, polymorphic: true
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_one_attached :image

  validates :name, :description, :price, :image, :status, presence: true
  validates :featured, presence: true, if: -> { featured.nil? }
  validates :name, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than: 0 }

  enum status: { available: 1, unavailable: 2 }
end
