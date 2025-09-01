# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentCreator do
  # Use let! to ensure the company is created before each test
  let!(:company) { create(:company) }
  let(:valid_attributes) { [attributes_for(:payment), attributes_for(:payment)] }
  let(:invalid_attributes) { [attributes_for(:payment, amount_cents: -10)] }

  describe '.call' do
    context 'with valid payment attributes' do
      it 'creates the correct number of payments' do
        expect do
          described_class.call(company: company, payments_attributes: valid_attributes)
        end.to change(Payment, :count).by(2)
      end

      it 'associates the payments with the correct company' do
        described_class.call(company: company, payments_attributes: valid_attributes)
        expect(Payment.first.company).to eq(company)
        expect(Payment.last.company).to eq(company)
      end

      it 'returns a successful result object' do
        result = described_class.call(company: company, payments_attributes: valid_attributes)
        expect(result).to be_success
        expect(result.created_records.size).to eq(2)
      end
    end

    context 'with empty or nil payment attributes' do
      it 'returns a failure result object and does not create payments' do
        expect do
          result = described_class.call(company: company, payments_attributes: [])
          expect(result).not_to be_success
          expect(result.error).to eq('Payments data cannot be empty')
        end.not_to change(Payment, :count)
      end
    end
  end
end
