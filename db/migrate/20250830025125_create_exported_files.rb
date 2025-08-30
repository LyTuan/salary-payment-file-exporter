class CreateExportedFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :exported_files do |t|
      t.string :filepath
      t.datetime :exported_at

      t.timestamps
    end
  end
end
