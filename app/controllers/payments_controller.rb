# frozen_string_literal: true

class PaymentsController < ApplicationController
  # POST /payments
  def create
    # The company is set by the AuthenticationMiddleware
    authenticated_company = request.env['current_company']

    # Validate the nested payments array using a dry-validation contract
    contract = ::Payments::CreateContract.new
    validation_result = contract.call(params.to_unsafe_h)

    return render json: { errors: validation_result.errors.to_h }, status: :bad_request if validation_result.failure?

    validated_data = validation_result.to_h

    # Security Check: Ensure the company_id in the payload matches the authenticated company
    if authenticated_company.id.to_s != validated_data[:company_id]
      return render json: { error: 'Payload company_id does not match authenticated company' }, status: :forbidden
    end

    # If validation passes, proceed with the service object
    result = PaymentCreator.call(
      company: authenticated_company,
      payments_attributes: validated_data[:payments]
    )

    if result.success?
      render json: { message: 'Payments created successfully.', count: result.created_records.size }, status: :created
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
