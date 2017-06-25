class AddDeltaToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :delta, :boolean
  end
end
