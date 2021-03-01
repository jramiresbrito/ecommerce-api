class Game < ApplicationRecord
  belongs_to :system_requirement
  has_one :product, as: :productable
  has_many :licenses, dependent: :destroy

  validates :mode, :release_date, :developer, presence: true

  enum mode: { pvp: 1, pve: 2, both: 3 }
end
