class SystemRequirement < ApplicationRecord
  include NameSearchable
  include Paginatable

  validates :name, :processor, :video_board, :memory, :operational_system, :storage,
            presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :games, dependent: :restrict_with_error
end
