class UserTitle < ApplicationRecord
  belongs_to :user
  belongs_to :title
  
  validates :user_id, uniqueness: { scope: :title_id }
  validates :earned_at, presence: true
end

