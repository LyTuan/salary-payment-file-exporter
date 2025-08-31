# frozen_string_literal: true

class ExportedFile < ApplicationRecord
  has_many :payments
end
