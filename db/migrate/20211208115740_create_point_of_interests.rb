class CreatePointOfInterests < ActiveRecord::Migration[6.1]
  def change
    create_table :point_of_interests do |t|
      t.string :name
      t.string :description
      t.float :latitude
      t.float :longitude
      t.integer :variant, default: 0
      t.references :moto_route, foreign_key: true
  

      t.timestamps
    end
  end
end
