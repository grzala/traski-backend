require "httparty"
require 'nokogiri'



def fits_seach_string?(string_to_search, search_string)
    return string_to_search.length > search_string.length && string_to_search[0...search_string.length] == search_string
end

def _get_accidents_data(dateFrom, dateTo)
    # accepted argument format: "degrees*minutes'seconds"
    degrees_to_dms = lambda2 = ->(x) do
        x = x.split("*")
        degrees = x[0].to_f
        x = x[1].split("'")
        minutes = x[0].to_f
        seconds = x[1].to_f

        (seconds / 3600.0) + (minutes / 60.0) + degrees
    end 

    sewik_url = "http://sewik.pl"

    html = HTTParty.get(sewik_url + '/search')

    cookie = html.headers["set-cookie"].split(";")[0]

    get_response = Nokogiri::HTML(html.body)
    form_token = get_response.css("input#filter_form__token").attr("value")


    post_response = HTTParty.post(sewik_url + '/search',
        { 
            :body =>  {
                "filter_form[county]" => "",
                "filter_form[locality]" => "",
                "filter_form[streets][0]" =>	"",
                "filter_form[streets][1]" =>	"",
                "filter_form[streets][2]" =>	"",
                "filter_form[streets][3]" =>	"",
                "filter_form[accidentSite]" =>	"",
                "filter_form[roadType]" =>	"",
                "filter_form[light]" =>	"",
                "filter_form[trafficLights]" =>	"",
                "filter_form[intersectionType]" =>	"",
                "filter_form[accidentType]" =>	"",
                "filter_form[driversCause]" =>	"",
                "filter_form[pedestriansCause]" =>	"",
                "filter_form[otherCause]" =>	"",
                "filter_form[injury]" =>	"",
                "filter_form[pedestriansPresence]" =>	"",
                "filter_form[accidents]" => "",
                "filter_form[voivodeship]" => "",
                "filter_form[fromDate]" => dateFrom,
                "filter_form[toDate]" => dateTo,
                "filter_form[vehicleType][]" => "2",
                "filter_form[categories]" => "Pojazdy",
                "filter_form[_token]" => form_token,
            },
            :headers => { 
                'Content-Type' => 'application/x-www-form-urlencoded', 
                'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
                'Cookie' => cookie,
                "User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:96.0) Gecko/20100101 Firefox/96.0",
            }
        })
        

    post_response = Nokogiri::HTML(post_response.body)

    results = post_response.css("table").css("tr")
    results = results[1...results.length]

    results = results.map { |item| item.css('a').attr("href").to_s }

    # for debug
    # results = [results[1]]
    # results = ['/accident/109468626']

    accident_data = []

    results.each do |accident_link|
        html = HTTParty.get(sewik_url + accident_link)
        response = Nokogiri::HTML(html.body)

        data = {
            :original_id => accident_link.split("/")[-1],
            :injury => 0
        }

        lis = response.css("li")

        coord_search_string = "Współrzędne geograficzne:"
        date_search_string = "Data:"
        injury_search_string = "Obrażenia:"
        lis.each do |li_element| 
            li_element = li_element.inner_html
            if (fits_seach_string?(li_element, coord_search_string))
                coords = li_element.split(": ")[1..-1].join("").split(",")

                # convert to DMS if in degrees
                coords = coords.map &degrees_to_dms if (coords[0].include? "*")
                data[:latitude] = coords[1]
                data[:longitude] = coords[0]
            end

            if (fits_seach_string?(li_element, date_search_string))
                data[:date] = li_element.split(": ")[1]
            end
        end

        vehicle_lis = response.css("ol li")
        vehicle_lis.each do |li_element|
            strongs = li_element.css("strong")
            if strongs.length > 0 
                vehicle_type = li_element.css("strong")[0].inner_html
                if vehicle_type.split(" ")[0] == 'Motocykl'
                    li_element.css("ul li").each do |vehicle_details|
                        vehicle_details = vehicle_details.inner_html
                        if (fits_seach_string?(vehicle_details, injury_search_string)) 
                            if vehicle_details.include? "lekko"
                                data[:injury] = 1 if 1 > data[:injury]
                            elsif vehicle_details.include? "ciężko"
                                data[:injury] = 2 if 2 > data[:injury]
                            elsif vehicle_details.include? "Śmierć"
                                data[:injury] = 3 if 3 > data[:injury]
                            end
                        end
                    end
                end
            end
            
        end

        accident_data << data
    end

    return accident_data
end

# use 10 days intervals, as SEWIK's response length is limited but no details are provided
def get_accidents_data(dateFrom, dateTo)    
    result = []
    while (dateTo - dateFrom).to_i > 10

        result += _get_accidents_data(dateFrom.strftime("%Y-%m-%d"), (dateFrom + 10).strftime("%Y-%m-%d"))
        dateFrom += 11 # plus 11, because dateTo is included in SEWIK's response
    end
    result += _get_accidents_data(dateFrom.strftime("%Y-%m-%d"), dateTo.strftime("%Y-%m-%d"))

    return result
end


namespace :sewik do
    desc 'Scrape accident data from SEWIK. Requires dateFrom and dateTo as arguments (%Y-%m-%d). Both dates are inclusive. Call task using rake sewik:scrape[dateFrom, dateTo]'
    task :scrape, [:dateFrom, :dateTo] => :environment do |env, args|
        if args[:dateFrom] == nil || args[:dateTo] == nil
            puts 'Requires dateFrom and dateTo as arguments (%Y-%m-%d). Both dates are inclusive. Call task using rake sewik:scrape[dateFrom, dateTo]'
            fail
        end

        dateFrom = Date::strptime(args[:dateFrom], "%Y-%m-%d")
        dateTo = Date::strptime(args[:dateTo], "%Y-%m-%d")

        if (dateTo < dateFrom) 
            puts "dateTo must be bigger than dateFrom"
            fail
        end

        puts "Scraping accidents from sewik between #{dateFrom} - #{dateTo}"

        data = get_accidents_data(dateFrom, dateTo)

        puts "Data scraped, inserting to db"
        new_accidents = []
        
        Accident.transaction do
            data.each do |accident_data|
                # ignore accidents with no geolocation. These are rare
                if accident_data[:latitude] == nil || accident_data[:longitude] == nil
                    next
                end

                # ignore duplicates
                if Accident.find_by(original_id: accident_data[:original_id]) == nil
                    accident = Accident.create!(accident_data)
                    new_accidents << accident
                end
            end
        end
        puts "Inserted " + new_accidents.length.to_s + " accidents"

    end


end
