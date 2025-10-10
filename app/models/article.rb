class Article < ApplicationRecord
  belongs_to :day
  has_many :content_items, dependent: :nullify

  validates :title, presence: true
  validates :body, presence: true
end
