class CreateStats < ActiveRecord::Migration[5.2]
  def change
    create_table :stats do |t|
      t.integer :thermostat_id
      t.string :sensor_type
      t.float :avg
      t.float :min
      t.float :max

      t.timestamps
    end
  end
end
