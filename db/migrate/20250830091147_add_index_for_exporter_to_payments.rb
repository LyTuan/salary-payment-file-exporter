class AddIndexForExporterToPayments < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  def change
    add_index :payments, [:status, :pay_date], algorithm: :concurrently
  end
end
