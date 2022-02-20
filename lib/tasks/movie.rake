require 'open-uri' # warning: calling URI.open via Kernel#open is deprecated, call URI.open directly or use URI#open

namespace :movie do
  task add_city_and_theater: :environment do
    print 'URL: '
    url = STDIN.gets.chomp
    puts
    # url = "https://tw.movies.yahoo.com/movietime_result.html/id=#{id}"
    doc = Nokogiri::HTML(URI.open(url))

    doc.css('.area_timebox').each do |box|
      city_selector = box.css('.area_title')
      city = City.find_or_create_by(name: city_selector.text)
      puts city.name
      box.css('.area_time._c').each do |theater|
        city.theaters.find_or_create_by(name: theater.css('.adds').first.css('a').text)
      end
    end
  end

  # usage: rails movie:update_theater
  # for create or update cities and theaters
  task update_theater: :environment do
    doc = Nokogiri::HTML(URI.open('https://movies.yahoo.com.tw/theater_list.html'))

    doc.css('.theater_content').each do |box|
      city_selector = box.css('.theater_top')
      city = City.find_or_create_by(name: city_selector.text)
      puts city.name

      box.css('li:not(.tab)').each do |theater_seletor|
        theater = city.theaters.find_or_initialize_by(name: theater_seletor.css('.name > a').text)
        address = theater_seletor.css('.adds').text
        theater.address = address
        address.match(/.+市(.{2}區).+/i)
        theater.region = $1
        theater.phone = theater_seletor.css('.tel').text
        theater.save

        puts theater.name
      end
    end
  end

  # usage: rails movie:update_movies
  task update_movies: :environment do
    doc = Nokogiri::HTML(URI.open("https://tw.movies.yahoo.com/"))
    options = doc.css('#sbox_mid > option')
    options.shift

    id_name_mapping = {}
    options.each do |movie|
      yahoo_movie_id, movie_name = movie.values
      puts movie_name
      Movie.from_yahoo(yahoo_movie_id, movie_name) if !id_name_mapping[yahoo_movie_id]
      id_name_mapping[yahoo_movie_id] = movie_name
    end
  end
end
