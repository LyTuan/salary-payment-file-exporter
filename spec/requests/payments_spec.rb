# frozen_string_literal: true

# spec/requests/payments_spec.rb
require 'rails_helper'

RSpec.describe 'Payments API', type: :request do
  # Use let! to ensure the company and its API key are created before tests run.
  let!(:company) { create(:company) }
  let(:api_key) { company.api_key }
  let(:headers) { { 'Authorization' => "Bearer #{api_key}", 'Content-Type' => 'application/json' } }

  describe 'POST /payments' do
    # Use `attributes_for` to get a hash of valid attributes from the factory.
    let(:valid_payment_attributes) { attributes_for(:payment) }
    let(:valid_payload) do
      { company_id: company.id.to_s, payments: [valid_payment_attributes] }
    end

    context 'with valid authentication and parameters' do
      it 'creates new payments and returns a 201 status' do
        expect do
          post '/payments', params: valid_payload.to_json, headers: headers
        end.to change(Payment, :count).by(1)

        expect(response).to have_http_status(:created)

        # Also test the response body for a more complete test
        json_response = response.parsed_body
        expect(json_response['message']).to eq('Payments created successfully.')
        expect(json_response['count']).to eq(1)
      end
    end

    context 'with invalid parameters' do
      # Helper to make the request and parse the response, reducing duplication
      def post_with_invalid_payment(overrides)
        invalid_attributes = attributes_for(:payment).merge(overrides)
        payload = { company_id: company.id.to_s, payments: [invalid_attributes] }
        post '/payments', params: payload.to_json, headers: headers
        response.parsed_body
      end

      it 'returns a 400 when amount_cents is not positive' do
        json_response = post_with_invalid_payment(amount_cents: 0)
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']['payments']['0']['amount_cents']).to include('must be greater than 0')
      end

      it 'returns a 400 when bank_bsb is invalid' do
        json_response = post_with_invalid_payment(bank_bsb: '123')
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']['payments']['0']['bank_bsb']).to include('is in invalid format')
      end

      it 'returns a 400 when pay_date is in the past' do
        json_response = post_with_invalid_payment(pay_date: Date.yesterday)
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']['payments']['0']['pay_date']).to include("can't be in the past")
      end

      it 'returns a 400 when company_id is missing' do
        post '/payments', params: { payments: [] }.to_json, headers: headers
        json_response = response.parsed_body
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']['company_id']).to include('is missing')
      end

      it 'returns a 403 when company_id does not match authenticated company' do
        other_company = create(:company)
        mismatched_payload = { company_id: other_company.id.to_s, payments: [valid_payment_attributes] }

        post '/payments', params: mismatched_payload.to_json, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid authentication' do
      it 'returns a 401 when token is missing' do
        post '/payments', params: valid_payload.to_json, headers: { 'Content-Type' => 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 401 when token is invalid' do
        invalid_headers = { 'Authorization' => 'Bearer invalid-token', 'Content-Type' => 'application/json' }
        post '/payments', params: valid_payload.to_json, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
