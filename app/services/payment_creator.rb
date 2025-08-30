class PaymentCreator
  # A custom error class for this service for better error handling.
  class CreationError < StandardError; end

  # The public interface for the service.
  # It's often convenient to have a class method `call` that hides the instantiation.
  def self.call(company:, payments_attributes:)
    new(company: company, payments_attributes: payments_attributes).call
  end

  def initialize(company:, payments_attributes:)
    @company = company
    @payments_attributes = payments_attributes || []
  end

  def call
    raise CreationError, "Payments data cannot be empty" if @payments_attributes.empty?

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

    records_to_insert # Return the array of hashes so the controller can get the count.
  end
end