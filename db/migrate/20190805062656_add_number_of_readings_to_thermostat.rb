class AddNumberOfReadingsToThermostat < ActiveRecord::Migration[5.2]
  def change
    add_column :thermostats, :number_of_readings, :integer
  end
end
