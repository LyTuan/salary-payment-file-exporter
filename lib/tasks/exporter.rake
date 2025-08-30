namespace :exporter do
  desc "Exports pending payments to a text file"
  task run: :environment do
    puts "Starting payment export job..."
    PaymentExporter.new.export!
  end
end