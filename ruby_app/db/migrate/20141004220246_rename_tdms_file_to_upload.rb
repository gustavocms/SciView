class RenameTdmsFileToUpload < ActiveRecord::Migration
  def change
    rename_table :tdms_files, :uploads
  end
end
