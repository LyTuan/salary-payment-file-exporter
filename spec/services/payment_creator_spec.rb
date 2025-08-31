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
    end

    context 'with empty or nil payment attributes' do
      it 'raises a CreationError' do
        expect { described_class.call(company: company, payments_attributes: []) }.to raise_error(PaymentCreator::CreationError)
        expect { described_class.call(company: company, payments_attributes: nil) }.to raise_error(PaymentCreator::CreationError)
      end
    end
  end
end
