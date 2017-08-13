class Movie
  def self.recommend
    movie_names = []
    doc = Nokogiri::HTML(open("https://tw.movies.yahoo.com/movie_intheaters.html?page=#{rand(1..8)}"))
    movies = doc.css('.release_movie_name')
    movies.each do |movie|
      movie_names << movie.css('a').first.text.split(' ').first
    end

    movie_names
  end

  def self.search(keyword)
    doc = Nokogiri::HTML(open(URI.encode("https://tw.movies.yahoo.com/moviesearch_result.html?keyword=#{keyword[0..100]}&type=movie&page=1")))
    m = doc.css('a').select{|m| m.text == '時刻表' }
    m = m.select{|m| m.attributes['href'] != nil }
    data = []
    if !m.first.nil?
      movie_name = doc.css('.release_movie_name').first.css('a').first.text
      url = m.first.attributes['href'].value
      doc = Nokogiri::HTML(open(url))

      times = doc.css('.area_time._c').first(20).compact.map do |where|
        times = where.css('.time .select').map do |time|
          time.text
        end.join(', ')

        data << where.css('.adds').first.css('a').text + "(#{where.css('.tapR').text})" + "\n" + times if times.present?

        times == '' ? nil : times
      end

      data << "目前沒有可觀看的時間!!!" if times.compact.blank?
    else
      data << "查無此電影!!!"
    end

    { name: movie_name, data: data }
  end
end
