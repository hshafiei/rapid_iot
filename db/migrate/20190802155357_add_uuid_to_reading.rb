class AddUuidToReading < ActiveRecord::Migration[5.2]
  def change
    add_column :readings, :uuid, :string
  end
end
