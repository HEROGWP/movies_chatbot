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

    options.each do |movie|
      yahoo_movie_id, movie_name = movie.values
      puts movie_name
      (0..4).each do |day|
        date = (Date.today + day.days).strftime("%Y-%m-%d")
        url = "https://movies.yahoo.com.tw/ajax/pc/get_schedule_by_movie?movie_id=#{yahoo_movie_id}&date=#{date}&area_id="
        response = HTTParty.get(url)
        response_data = response.parsed_response
        doc = Nokogiri::HTML(response_data['view'])
        movie = Movie.find_or_create_by(name: movie_name)

        data = {}
        doc.css('.area_timebox').each do |box|
          city_name = box.css('.area_title').text
          puts city_name
          city = City.find_or_create_by(name: city_name)

          box.css('.area_time._c').map do |theater|
            theater_name = theater.css('.adds').first.css('a').text
            type = theater.css('.tapR').first.text
            theater_record = city.theaters.find_or_create_by(name: theater_name)

            theater.css('label.select').each do |time|
              # TODO: 處理凌晨的問題
              start_time = Time.parse("#{date} #{time.text}")
              TimeTable.find_or_create_by(
                theater_type: type,
                theater_id: theater_record.id,
                movie_id: movie.id,
                start_time:  start_time
              )
            end
          end
        end

        info_url = "https://movies.yahoo.com.tw/movieinfo_main/#{yahoo_movie_id}"
        doc = Nokogiri::HTML(URI.open(info_url))
        picture_url = doc.css('.movie_intro_foto img').first.attributes['src'].value
        movie.update(times: data, url: info_url, picture_url: picture_url)
      end
    end
  end

end
