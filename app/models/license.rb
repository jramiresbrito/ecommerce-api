class License < ApplicationRecord
  include LikeSearchable
  include Paginatable

  belongs_to :game

  validates :key, :platform, :status, presence: true
  validates :key, uniqueness: { case_sensitive: false, scope: :platform }

  enum platform: { steam: 1, battle_net: 2, origin: 3 }
  enum status: { available: 1, in_use: 2, inactive: 3 }
end
