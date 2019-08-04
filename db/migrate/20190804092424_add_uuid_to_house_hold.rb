class AddUuidToHouseHold < ActiveRecord::Migration[5.2]
  def change
    add_column :house_holds, :uuid, :string
    add_index :house_holds, :uuid
  end
end
