# spec/requests/payments_spec.rb
require 'rails_helper'

RSpec.describe "Payments API", type: :request do
  # Use FactoryBot to create the company. `let` is lazy-loaded.
  let(:company) { create(:company) }

  describe "POST /payments" do
    # Use `attributes_for` to get a hash of valid attributes from the factory.
    let(:valid_payment_attributes) { attributes_for(:payment) }
    let(:valid_payload) do
      {
        payment: {
          company_id: company.id,
          payments: [valid_payment_attributes]
        }
      }
    end

    context "with valid parameters" do
      it "creates new payments and returns a 201 status" do
        expect do
          post "/payments", params: valid_payload, as: :json
        end.to change(Payment, :count).by(1)

        expect(response).to have_http_status(:created)

        # Also test the response body for a more complete test
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Payments created successfully.")
        expect(json_response["count"]).to eq(1)
      end
    end

    context "with invalid parameters" do
      # Helper to make the request and parse the response, reducing duplication
      def post_with_invalid_payment(overrides = {})
        invalid_attributes = attributes_for(:payment).merge(overrides)
        payload = { payment: { company_id: company.id, payments: [invalid_attributes] } }
        post "/payments", params: payload, as: :json
        JSON.parse(response.body)
      end

      it "returns a 400 when amount_cents is not positive" do
        json_response = post_with_invalid_payment(amount_cents: 0)

        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to include("Amount cents must be greater than 0")
      end

      it "returns a 400 when bank_bsb is invalid" do
        json_response = post_with_invalid_payment(bank_bsb: "123")

        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to include("Bank bsb must be 6 digits")
      end

      it "returns a 400 when pay_date is in the past" do
        json_response = post_with_invalid_payment(pay_date: Date.yesterday)

        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to include("Pay date can't be in the past")
      end
    end
  end
end