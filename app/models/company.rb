class Company < ApplicationRecord
  has_secure_token :api_key
  has_many :payments, dependent: :destroy
end