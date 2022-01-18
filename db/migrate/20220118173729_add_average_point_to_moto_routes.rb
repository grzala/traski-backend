class AddAveragePointToMotoRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :moto_routes, :average_lng, :float, default: 0.0
    add_column :moto_routes, :average_lat, :float, default: 0.0

    # re-save and let new after save hook populate this attribute
    MotoRoute.all.each {|m| m.save!}
  end


end
