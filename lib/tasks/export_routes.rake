require 'fileutils'


namespace :export do
    desc 'Export routes and pois to json'
    task :routes => :environment do |env, args|
        to_export = []

        MotoRoute.all.each_with_index do |route, i|
            to_export << route
            File.open('public/route_thumbnails/' + route.id.to_s + '.png', 'r') do |f|
                new_file = File.open('exports/img/' + i.to_s + '.png', 'w')
                new_file << f.read
                new_file.close
            end
        end


        dirname = "exports/MotoRoutes.json"
        File.open(dirname, 'w') do |f| 
            f.write(to_export.to_json({:include => [:point_of_interests]}))
        end
    end

end