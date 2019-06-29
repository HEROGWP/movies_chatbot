namespace :movie do
  task add_city_and_theater: :environment do
    print 'URL: '
    url = STDIN.gets.chomp
    puts
    # url = "https://tw.movies.yahoo.com/movietime_result.html/id=#{id}"

    doc = Nokogiri::HTML(open(url))

    doc.css('.area_timebox').each do |box|
      city_selector = box.css('.area_title')
      city = City.find_or_create_by(name: city_selector.text)
      puts city.name
      box.css('.area_time._c').each do |theater|
        city.theaters.find_or_create_by(name: theater.css('.adds').first.css('a').text)
      end
    end
  end

  task update_movies: :environment do
    pages = ENV['pages'] || 8
    paths = %w[movie_thisweek movie_intheaters]
    paths.each do |path|
      pages.to_i.times do |page|
        doc = Nokogiri::HTML(open(URI.encode("https://tw.movies.yahoo.com/#{path}.html?page=#{page + 1}")))
        timetables = doc.css('.btn_s_time.gabtn')
        timetables.each do |timetable|
          timetable_url = timetable.attributes['href'].value
          yahoo_movie_id ||= timetable_url.match(/id=(\d+)/i).captures.first
          (0..4).each do |day|
            date = (Date.today + day.days).strftime("%Y-%m-%d")
            url = "https://movies.yahoo.com.tw/ajax/pc/get_schedule_by_movie?movie_id=#{yahoo_movie_id}&date=#{date}&area_id="
            response = HTTParty.get(url)
            response_data = response.parsed_response
            doc = Nokogiri::HTML(response_data['view'])
            movie_name = doc.css('input').first.attr('data-movie_title')
            puts movie_name
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

            info_url = timetable_url.gsub('movietime_result', 'movieinfo_main')
            doc = Nokogiri::HTML(open(info_url))
            picture_url = doc.css('.movie_intro_foto img').first.attributes['src'].value
            movie.update(times: data, url: info_url, picture_url: picture_url)
          end
        end
      end
    end
  end
end
