class EncryptSecretKeyOnCompanies < ActiveRecord::Migration[8.0]
  def up
    add_column :companies, :client_key, :string
    add_column :companies, :secret_key, :text
    Company.find_each(&:save!)
    add_index :companies, :client_key, unique: true
    remove_column :companies, :api_key, :string, if_exists: true
  end

  def down
    add_column :companies, :api_key, :string
    add_index :companies, :api_key, unique: true
    remove_column :companies, :secret_key, :text
    remove_column :companies, :client_key, :string
  end
end
