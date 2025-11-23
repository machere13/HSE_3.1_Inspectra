class Article < ApplicationRecord
  belongs_to :week
  has_many :content_items, dependent: :nullify

  validates :title, presence: true
  validates :body, presence: true
end
