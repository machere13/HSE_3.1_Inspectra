class Title < ApplicationRecord
  has_many :user_titles, dependent: :destroy
  has_many :users, through: :user_titles
  
  validates :name, presence: true, uniqueness: true
end

