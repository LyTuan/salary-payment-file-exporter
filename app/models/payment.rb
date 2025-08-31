# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :company
  belongs_to :exported_file, optional: true

  # Enum for status: 0 -> pending, 1 -> exported
  enum :status, { pending: 0, exported: 1 }

  # Validations
  validates :employee_id, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: %w[AUD], message: "must be 'AUD'" }
  validates :bank_bsb, format: { with: /\A\d{6}\z/, message: 'must be 6 digits' }
  validates :bank_account, format: { with: /\A\d{6,9}\z/, message: 'must be 6-9 digits' }
  validates :pay_date, presence: true

  # Custom validation for pay_date
  validate :pay_date_cannot_be_in_the_past

  def pay_date_cannot_be_in_the_past
    errors.add(:pay_date, "can't be in the past") if pay_date.present? && pay_date < Date.today
  end
end
