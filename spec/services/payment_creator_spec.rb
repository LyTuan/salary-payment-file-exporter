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
        payments = described_class.call(company: company, payments_attributes: valid_attributes)
        expect(payments.first.company).to eq(company)
        expect(payments.last.company).to eq(company)
      end

      it 'returns the created payment records' do
        payments = described_class.call(company: company, payments_attributes: valid_attributes)
        expect(payments).to all(be_a(Payment))
        expect(payments.size).to eq(2)
      end
    end

    context 'with invalid payment attributes' do
      it 'raises RecordInvalid and does not create any payments' do
        expect do
          described_class.call(company: company, payments_attributes: invalid_attributes)
        end.to raise_error(ActiveRecord::RecordInvalid)
          .and change(Payment, :count).by(0)
      end

      it 'rolls back the transaction if one payment is invalid' do
        mixed_attributes = [attributes_for(:payment), attributes_for(:payment, bank_bsb: 'invalid')]
        expect do
          described_class.call(company: company, payments_attributes: mixed_attributes)
        end.to raise_error(ActiveRecord::RecordInvalid)
        expect(Payment.count).to eq(0)
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