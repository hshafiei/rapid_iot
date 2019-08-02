class AddHouseholdTokenToReading < ActiveRecord::Migration[5.2]
  def change
    add_column :readings, :household_token, :text
  end
end
