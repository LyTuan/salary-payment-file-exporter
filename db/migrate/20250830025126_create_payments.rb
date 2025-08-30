class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :company, null: false, foreign_key: true
      t.string :employee_id
      t.string :bank_bsb
      t.string :bank_account
      t.integer :amount_cents
      t.string :currency
      t.date :pay_date
      t.integer :status, default:0, null: false
      t.references :exported_file, null: false, foreign_key: true
      t.timestamps
    end
    add_index :payments, :status
  end
end
