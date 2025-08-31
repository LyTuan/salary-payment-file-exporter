# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :company # This automatically creates a company using its factory
    employee_id { "E#{rand(1000..9999)}" }
    bank_bsb { '062000' }
    bank_account { '12345678' }
    amount_cents { 50_000 }
    currency { 'AUD' }
    pay_date { Time.zone.today }
    status { :pending }
  end
end
