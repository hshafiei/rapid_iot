class CreateHouseHolds < ActiveRecord::Migration[5.2]
  def change
    create_table :house_holds do |t|
      t.text :token

      t.timestamps
    end
  end
end
