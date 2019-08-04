class AddUuidToStat < ActiveRecord::Migration[5.2]
  def change
    add_column :stats, :uuid, :string
    add_index :stats, :uuid
  end
end
