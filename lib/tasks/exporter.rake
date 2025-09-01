# frozen_string_literal: true

namespace :exporter do
  desc 'Exports pending payments to a text file'
  task run: :environment do
    puts 'Starting payment export job...'
    result = PaymentExporter.call
    if result.success?
      puts "Successfully exported #{result.count} payments to #{result.filepath}"
    else
      puts "Export failed: #{result.error}"
    end
  end
end
