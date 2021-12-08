class CreateMotoRouteFavourites < ActiveRecord::Migration[6.1]
  def change
    create_table :moto_route_favourites do |t|

      t.references :user, foreign_key: true
      t.references :moto_route, foreign_key: true

      t.timestamps
    end
  end
end
