# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe PaymentExporter do
  # Define test paths and ensure they are cleaned up
  let(:export_path) { Rails.root.join('tmp/spec/exports') }
  let(:outbox_path) { Rails.root.join('tmp/spec/outbox') }

  before do
    # Stub the constants to use temporary paths for testing
    stub_const('PaymentExporter::EXPORT_PATH', export_path)
    stub_const('PaymentExporter::OUTBOX_PATH', outbox_path)

    # Ensure directories are clean before the test
    FileUtils.rm_rf(export_path)
    FileUtils.rm_rf(outbox_path)
    FileUtils.mkdir_p(export_path)
    FileUtils.mkdir_p(outbox_path)
  end

  after do
    # Clean up directories after the test
    FileUtils.rm_rf(export_path)
    FileUtils.rm_rf(outbox_path)
  end

  describe '#export!' do
    context 'when there are pending payments to export' do
      # Payments that should be exported
      let!(:payment_to_export1) { create(:payment, pay_date: Time.zone.today) } # Due today
      let!(:payment_to_export2) do # Overdue payment
        travel_to 1.day.ago do
          create(:payment, pay_date: Time.zone.today) # Created yesterday, for yesterday
        end
      end

      # Payments that should NOT be exported
      let!(:future_payment) { create(:payment, pay_date: 1.day.from_now.to_date) }
      let!(:exported_payment) { create(:payment, status: :exported) }

      it 'creates one new ExportedFile record' do
        expect { described_class.new.export! }.to change(ExportedFile, :count).by(1)
      end

      it 'updates the status of due payments to exported' do
        described_class.new.export!
        expect(payment_to_export1.reload.status).to eq('exported')
        expect(payment_to_export2.reload.status).to eq('exported')
      end

      it 'associates the exported payments with the new file record' do
        described_class.new.export!
        exported_file = ExportedFile.last
        expect(payment_to_export1.reload.exported_file).to eq(exported_file)
        expect(payment_to_export2.reload.exported_file).to eq(exported_file)
      end

      it 'does not change the status of payments that are not due or already exported' do
        described_class.new.export!
        expect(future_payment.reload.status).to eq('pending')
        expect(exported_payment.reload.status).to eq('exported')
      end

      it 'creates a correctly formatted file and moves it to the outbox' do
        described_class.new.export!

        filename = "#{Time.zone.today.strftime('%Y%m%d')}_payments.txt"
        final_filepath = outbox_path.join(filename)

        expect(File.exist?(final_filepath)).to be true

        # Verify file content
        csv_content = CSV.read(final_filepath)
        expect(csv_content.size).to eq(3) # 1 header + 2 payments
        expect(csv_content[1]).to include(payment_to_export1.employee_id)
        expect(csv_content[2]).to include(payment_to_export2.employee_id)
      end
    end

    context 'when there are no pending payments to export' do
      it 'does not create any new records or files' do
        expect { described_class.new.export! }.not_to change(ExportedFile, :count)
        expect(Dir.children(outbox_path)).to be_empty
      end
    end
  end
end