class PaymentsController < ApplicationController
  # POST /payments
  def create
    company = Company.find_by(id: payment_params[:company_id])
    unless company
      return render json: { error: "Company not found" }, status: :bad_request
    end

    # 1. Validate all incoming payments before creating any.
    # This ensures atomicity at the business logic level.
    payments_attributes = payment_params[:payments] || []
    payments_to_validate = payments_attributes.map { |attrs| company.payments.build(attrs.to_h) }

    # Find the first invalid payment to return its specific errors.
    invalid_payment = payments_to_validate.find(&:invalid?)
    if invalid_payment
      return render json: { errors: invalid_payment.errors.full_messages }, status: :bad_request
    end

    # 2. If all are valid, proceed with high-performance bulk creation.
    created_records = PaymentCreator.call(
      company: company,
      payments_attributes: payments_attributes
    )

    render json: { message: "Payments created successfully.", count: created_records.size }, status: :created

  # Rescue from service-level or unexpected database errors.
  rescue PaymentCreator::CreationError, StandardError => e
    render json: { error: "An unexpected error occurred: #{e.message}" }, status: :bad_request
  end

  private

  def payment_params
    params.require(:payment).permit(
      :company_id,
      payments: [
        :employee_id, :bank_bsb, :bank_account, :amount_cents, :currency, :pay_date
      ]
    )
  end
end