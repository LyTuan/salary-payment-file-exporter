# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Find or initialize the company to avoid creating duplicates.
company = Company.find_or_initialize_by(name: 'Default Company')

# Ensure keys are generated if they don't exist on an old record.
# The `has_secure_token` callbacks only run on create, so we handle existing records manually.
company.regenerate_client_key if company.client_key.blank?
company.regenerate_secret_key if company.secret_key.blank?

# Save the company if it's a new record or if keys were just generated.
company.save! if company.new_record? || company.changed?

puts 'Seed data created.'
puts "  Client-Key (for X-Client-Key header): #{company.client_key}"
puts "  Secret-Key (for Authorization: Bearer header): #{company.secret_key}"
puts 'Use these keys in your API client.'
