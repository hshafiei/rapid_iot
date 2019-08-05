class AddSumToStat < ActiveRecord::Migration[5.2]
  def change
    add_column :stats, :sum, :float
  end
end
