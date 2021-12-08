class CreateMotoRoutes < ActiveRecord::Migration[6.1]
  def change
    create_table :moto_routes do |t|
      t.string :name
      t.string :description
      t.string :coordinates_json_string
      t.date :open_start
      t.date :open_end
      t.integer :time_to_complete_h
      t.integer :time_to_complete_m
      t.integer :difficulty
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
