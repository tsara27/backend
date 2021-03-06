namespace :indexing do
  desc "Copy data from Place table to Search table"
  task search: :environment do
  	places = Place.all

  	places.each do |row|
      
      update_search = Index.find_by(id: row.id)

      if update_search
        update_search.id = row.id
        update_search.name = row.name 
        update_search.address = row.address 
        update_search.postal_code = row.postal_code 
        update_search.phone = row.phone
        update_search.fax = row.fax
        update_search.email = row.email
        update_search.website = row.website
        update_search.latitude = row.latitude
        update_search.longitude = row.longitude
        if row.city
          update_search.country_name = row.city.country.name
          update_search.city_name = row.city.name
          update_search.city_latitude = row.city.latitude
          update_search.city_longitude = row.city.longitude
        else
          update_search.country_name = row.country.name
        end
        update_search.category_name = row.category.name
        update_search.save
      else
        search = Index.new
        search.id = row.id
        search.name = row.name 
        search.address = row.address 
        search.postal_code = row.postal_code 
        search.phone = row.phone
        search.fax = row.fax
        search.email = row.email
        search.website = row.website
        search.latitude = row.latitude
        search.longitude = row.longitude
        if row.city
          search.country_name = row.city.country.name
          search.city_name = row.city.name
          search.city_latitude = row.city.latitude
          search.city_longitude = row.city.longitude
        else
          search.country_name = row.country.name
        end
        search.category_name = row.category.name
        search.save
      end
      
  	end
  end

  desc "Copy data from place table to elastic search"
  task elastic: :environment do
    places = Place.all

    places.each do |row|
      query = Jbuilder.encode do |json|
        json.id row.id
        json.name row.name
        json.address row.address
        json.postal_code row.postal_code
        json.phone row.phone
        json.fax row.fax
        json.email row.email
        json.website row.website
        json.latitude row.latitude
        json.longitude row.longitude
        if row.city
          json.country_name row.city.country.name
          json.city_name row.city.name
          json.city_latitude row.city.latitude
          json.city_longitude row.city.longitude
        else
          json.country_name row.country.name
        end
        json.category_name row.category.name
      end

      # send to elasticsearch
      uri = URI("http://128.199.139.216:9200/places/place/#{row.id}")
      req = Net::HTTP::Put.new(uri)
      req.body = query

      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
        http.request req
      end

      puts res.body
    end
    
  end
end
