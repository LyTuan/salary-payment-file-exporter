# spec/models/payment_spec.rb
require 'rails_helper'

RSpec.describe Payment, type: :model do
  # Use subject and build from factory_bot for a clean setup
  subject(:payment) { build(:payment) }

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:exported_file).optional }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, exported: 1) }
  end

  describe 'validations' do
    it { should be_valid } # The factory should produce a valid object

    it { should validate_presence_of(:employee_id) }
    it { should validate_numericality_of(:amount_cents).is_greater_than(0) }
    it { should validate_inclusion_of(:currency).in_array(%w[AUD]).with_message("must be 'AUD'") }

    it { should allow_value('123456').for(:bank_bsb) }
    it { should_not allow_value('12345').for(:bank_bsb).with_message("must be 6 digits") }
    it { should_not allow_value('1234567').for(:bank_bsb).with_message("must be 6 digits") }
    it { should_not allow_value('abcdef').for(:bank_bsb).with_message("must be 6 digits") }

    it { should allow_value('123456').for(:bank_account) }
    it { should allow_value('123456789').for(:bank_account) }
    it { should_not allow_value('12345').for(:bank_account).with_message("must be 6-9 digits") }
    it { should_not allow_value('1234567890').for(:bank_account).with_message("must be 6-9 digits") }
    it { should_not allow_value('abcdef').for(:bank_account).with_message("must be 6-9 digits") }

    it { should validate_presence_of(:pay_date) }

    context 'when pay_date is in the past' do
      subject(:payment) { build(:payment, pay_date: Date.yesterday) }

      it 'is invalid' do
        expect(payment).not_to be_valid
        expect(payment.errors[:pay_date]).to include("can't be in the past")
      end
    end

    context 'when pay_date is today' do
      subject(:payment) { build(:payment, pay_date: Date.today) }
      it { should be_valid }
    end
  end
end