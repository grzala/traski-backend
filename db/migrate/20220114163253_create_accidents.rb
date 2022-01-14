class CreateAccidents < ActiveRecord::Migration[6.1]
  def change
    create_table :accidents do |t|
      t.float :latitude
      t.float :longitude
      t.date :date
      t.string :original_id
      t.integer :injury, default: 0

      t.timestamps
    end
  end
end
