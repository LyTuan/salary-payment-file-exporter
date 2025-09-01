# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'ostruct'

# This should be in app/services/
class PaymentExporter < ApplicationService
  EXPORT_PATH = Rails.root.join(
    ENV.fetch('EXPORT_PATH', Rails.application.credentials[:export_path].presence || 'exports')
  )

  OUTBOX_PATH = Rails.root.join(
    ENV.fetch('OUTBOX_PATH', Rails.application.credentials[:outbox_path].presence || 'outbox')
  )

  def call
    # Find payments that are pending and due today or earlier
    payments_to_export = Payment.pending.where(pay_date: ..Time.zone.today)

    if payments_to_export.none?
      Rails.logger.debug 'No pending payments to export.'
      return OpenStruct.new(success?: true, count: 0, filepath: nil)
    end

    # Capture the count before the records are updated.
    export_count = payments_to_export.count

    # Ensure the export directory exists
    FileUtils.mkdir_p(EXPORT_PATH)

    filename = "#{Time.zone.today.strftime('%Y%m%d')}_payments.txt"
    filepath = EXPORT_PATH.join(filename)

    exported_file_record = nil

    ActiveRecord::Base.transaction do
      # 1. Create the ExportedFile record
      exported_file_record = ExportedFile.create!(
        filepath: filepath.to_s,
        exported_at: Time.current
      )

      # 2. Generate the export file efficiently
      generate_file(filepath, payments_to_export) # Pass the relation, not the loaded array

      # 3. Update payments to 'exported' status and link to the file
      payments_to_export.update_all(
        status: Payment.statuses[:exported],
        exported_file_id: exported_file_record.id
      )
    end

    # Move file after the transaction is successfully committed
    simulate_sftp_upload(filepath)
    OpenStruct.new(success?: true, count: export_count, filepath: filepath)
  rescue StandardError => e
    # Log the full error for debugging
    Rails.logger.error("Payment export failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    OpenStruct.new(success?: false, error: "An unexpected error occurred during export: #{e.message}")
  end

  private

  def generate_file(filepath, payments)
    CSV.open(filepath, 'w') do |csv|
      # Add headers (optional, but good practice)
      csv << %w[COMPANY_ID EMPLOYEE_ID BSB ACCOUNT AMOUNT_CENTS CURRENCY PAY_DATE]
      # Use find_each to process records in memory-efficient batches
      payments.find_each(batch_size: 1000) do |p|
        csv << [p.company_id, p.employee_id, p.bank_bsb, p.bank_account, p.amount_cents, p.currency, p.pay_date]
      end
    end
  end

  # ... inside PaymentExporter class ...

  def simulate_sftp_upload(filepath)
    FileUtils.mkdir_p(OUTBOX_PATH)
    FileUtils.mv(filepath, OUTBOX_PATH)
    Rails.logger.debug { "Simulated SFTP upload: Moved #{File.basename(filepath)} to #{OUTBOX_PATH}" }
  end
end
