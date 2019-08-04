class AddUuidToThermostat < ActiveRecord::Migration[5.2]
  def change
    add_column :thermostats, :uuid, :string
    add_index :thermostats, :uuid
  end
end
