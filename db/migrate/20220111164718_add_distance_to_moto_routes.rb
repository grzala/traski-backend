class AddDistanceToMotoRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :moto_routes, :distance, :float, default: 0.0
  end
end
