class Day < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :content_items, dependent: :destroy

  validates :number, presence: true, uniqueness: true, inclusion: { in: 1..15 }
  validates :title, presence: true
end
