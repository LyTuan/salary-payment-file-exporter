# frozen_string_literal: true

class Company < ApplicationRecord
  # Encrypt the secret_key attribute before saving it to the database.
  encrypts :secret_key

  has_secure_token :client_key # This is the public, non-secret identifier.
  has_secure_token :secret_key # This generates the plaintext secret before it gets encrypted.
  has_many :payments, dependent: :destroy
end
