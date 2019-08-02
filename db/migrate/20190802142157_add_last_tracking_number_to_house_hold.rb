class AddLastTrackingNumberToHouseHold < ActiveRecord::Migration[5.2]
  def change
    add_column :house_holds, :tracking_number, :integer, default: 0
  end
end
