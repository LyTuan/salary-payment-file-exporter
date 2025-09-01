# frozen_string_literal: true

require 'ostruct'

class PaymentCreator < ApplicationService
  def initialize(company:, payments_attributes:)
    @company = company
    @payments_attributes = payments_attributes || []
  end

  def call
    return OpenStruct.new(success?: false, error: 'Payments data cannot be empty') if @payments_attributes.empty?

    # For high-performance bulk inserts, `insert_all!` is significantly faster than
    # creating records one by one, as it performs a single SQL INSERT statement.
    # Note: `insert_all!` bypasses Active Record callbacks and model validations by default.
    # We assume data is pre-validated or we rely on database constraints.
    now = Time.current
    records_to_insert = @payments_attributes.map do |attrs|
      attrs.to_h.merge(
        company_id: @company.id,
        created_at: now,
        updated_at: now
      )
    end

    # This will raise a database-level error (e.g., ActiveRecord::NotNullViolation) on failure.
    Payment.insert_all!(records_to_insert)
    OpenStruct.new(success?: true, created_records: records_to_insert)
  rescue ActiveRecord::ActiveRecordError => e
    # Catch potential database errors from `insert_all!` and return a failure object.
    OpenStruct.new(success?: false, error: e.message)
  end
end
