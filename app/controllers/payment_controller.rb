class PaymentsController < ApplicationController
  # POST /payments
  def create
    company = Company.find_by(id: payment_params[:company_id])
    unless company
      return render json: { error: "Company not found" }, status: :bad_request
    end

    # Use a transaction to ensure all payments are created or none are.
    payments = []
    ActiveRecord::Base.transaction do
      payments = payment_params[:payments].map do |p|
        company.payments.create!(p)
      end
    end

    render json: { message: "Payments created successfully.", count: payments.size }, status: :created

    # Rescue from validation errors to return a 400 Bad Request
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :bad_request
    # Rescue from other potential errors
  rescue StandardError => e
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