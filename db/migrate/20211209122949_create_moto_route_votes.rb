class CreateMotoRouteVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :moto_route_votes do |t|

      t.references :user, foreign_key: true
      t.references :moto_route, foreign_key: true

      t.integer :score

      t.timestamps
    end
  end
end
