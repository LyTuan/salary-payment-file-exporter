# frozen_string_literal: true

module Payments
  class CreateContract < Dry::Validation::Contract
    # This contract validates an array of payment hashes.
    params do
      required(:company_id).filled(:string)
      required(:payments).array(:hash) do
        required(:employee_id).filled(:string)
        required(:amount_cents).filled(:integer, gt?: 0)
        required(:currency).filled(:string, included_in?: %w[AUD])
        required(:bank_bsb).filled(:string, format?: /\A\d{6}\z/)
        required(:bank_account).filled(:string, format?: /\A\d{6,9}\z/)
        required(:pay_date).filled(:date)
      end
    end

    rule(:payments).each do |index:|
      if value[:pay_date] && value[:pay_date] < Time.zone.today
        key([:payments, index,
             :pay_date]).failure("can't be in the past")
      end
    end

    rule(:company_id) do
      key.failure('must correspond to an existing company') unless Company.exists?(id: value)
    end
  end
end
