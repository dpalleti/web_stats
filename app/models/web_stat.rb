class WebStat < ApplicationRecord
  # Add validations to check data integrity
  validates :url, presence: true
  validates :created_at, presence: true
  validates :hash, presence: true, length: { is: 32 }
end
