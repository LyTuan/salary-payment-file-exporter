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

    ActiveRecord::Base.transaction do
      @payments_attributes.map do |payment_attrs|
        # The create! method will raise ActiveRecord::RecordInvalid on failure,
        # which will be caught by the controller and trigger a transaction rollback.
        @company.payments.create!(payment_attrs.to_h)
      end
    end
  end
end