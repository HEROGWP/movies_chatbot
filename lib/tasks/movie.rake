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
    pages.times do |page|
      doc = Nokogiri::HTML(open(URI.encode("https://tw.movies.yahoo.com/movie_intheaters.html?page=#{page + 1}")))
      timetables = doc.css('.btn_s_time.gabtn')
      timetables.each do |timetable|
        doc = Nokogiri::HTML(open(timetable.attributes['href'].value))
        movie_name = doc.css('.inform_title').children.first.text.split("\n").first
        puts movie_name

        data = {}
        doc.css('.area_timebox').each do |box|
          city_name = box.css('.area_title').text
          puts city_name
          city = City.find_or_create_by(name: city_name)

          data[city_name] = []
          box.css('.area_time._c').map do |theater|
            times = theater.css('.time._c li.select').map do |time|
              time.text
            end.join(', ')

            theater_name = theater.css('.adds').first.css('a').text
            theater_description = "#{theater_name}(#{theater.css('.tapR').text})"
            puts theater_description
            city.theaters.find_or_create_by(name: theater_name, description: theater_description)
            data[city_name] << "#{theater_description}\n#{times}" if times.present?
          end
        end

        movie = Movie.find_or_create_by(name: movie_name)
        movie.update(times: data)
        PP.pp data
      end
    end
  end
end
