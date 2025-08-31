# frozen_string_literal: true

class AddIndexForExporterToPayments < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  def change
    add_index :payments, %i[status pay_date], algorithm: :concurrently
  end
end
