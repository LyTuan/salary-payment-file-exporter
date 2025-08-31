# frozen_string_literal: true

namespace :performance do
  desc 'Seeds the database with a large volume of payments for performance testing'
  task seed: :environment do
    puts 'Seeding performance data...'

    company = Company.first!
    records_to_create = ENV.fetch('COUNT', '100000').to_i
    batch_size = 10_000

    puts "Creating #{records_to_create} payment records for Company ID: #{company.id}..."

    (records_to_create / batch_size).times do
      now = Time.current
      payments_batch = Array.new(batch_size) do
        {
          company_id: company.id,
          employee_id: "PERF-#{SecureRandom.hex(4)}",
          bank_bsb: '062000',
          bank_account: rand(100_000..999_999_999).to_s,
          amount_cents: rand(1000..100_000),
          currency: 'AUD',
          pay_date: Date.today - rand(0..5).days,
          status: 0, # pending
          created_at: now,
          updated_at: now
        }
      end
      Payment.insert_all!(payments_batch)
      print '.'
    end
    puts "\nDone."
  end
end
