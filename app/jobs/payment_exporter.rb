require 'csv'
require 'fileutils'

class PaymentExporter
  # EXPORT_PATH = Rails.root.join('exports')
  EXPORT_PATH = Rails.root.join(Rails.application.credentials.export_path)
  OUTBOX_PATH = Rails.root.join(Rails.application.credentials.outbox_path)

  def export!
    # Find payments that are pending and due today or earlier
    payments_to_export = Payment.pending.where("pay_date <= ?", Date.today)

    return if payments_to_export.empty?

    # Ensure the export directory exists
    FileUtils.mkdir_p(EXPORT_PATH)

    filename = "#{Date.today.strftime('%Y%m%d')}_payments.txt"
    filepath = EXPORT_PATH.join(filename)

    exported_file_record = nil

    ActiveRecord::Base.transaction do
      # 1. Create the ExportedFile record
      exported_file_record = ExportedFile.create!(
        filepath: filepath.to_s,
        exported_at: Time.current
      )

      # 2. Generate the export file
      generate_file(filepath, payments_to_export)

      # 3. Update payments to 'exported' status and link to the file
      payments_to_export.update_all(
        status: Payment.statuses[:exported],
        exported_file_id: exported_file_record.id
      )

      # ... inside the export! method, after the transaction block ...
      simulate_sftp_upload(filepath) if exported_file_record
    end

    puts "Successfully exported #{payments_to_export.count} payments to #{filepath}"
  end

  private

  def generate_file(filepath, payments)
    CSV.open(filepath, "w") do |csv|
      # Add headers (optional, but good practice)
      csv << %w[COMPANY_ID EMPLOYEE_ID BSB ACCOUNT AMOUNT_CENTS CURRENCY PAY_DATE]
      payments.each do |p|
        csv << [p.company_id, p.employee_id, p.bank_bsb, p.bank_account, p.amount_cents, p.currency, p.pay_date]
      end
    end
  end

  # ... inside PaymentExporter class ...
  private

  def simulate_sftp_upload(filepath)
    outbox_path = Rails.root.join('outbox')
    FileUtils.mkdir_p(outbox_path)
    FileUtils.mv(filepath, outbox_path)
    puts "Simulated SFTP upload: Moved #{File.basename(filepath)} to #{outbox_path}"
  end
end