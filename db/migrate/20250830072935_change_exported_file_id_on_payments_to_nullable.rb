# frozen_string_literal: true

class ChangeExportedFileIdOnPaymentsToNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :payments, :exported_file_id, true
  end
end
