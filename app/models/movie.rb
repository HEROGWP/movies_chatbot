class Movie < ApplicationRecord
  has_many :time_tables
  has_many :clients

  store :times

  def self.recommend
    movie_names = []
    doc = Nokogiri::HTML(open("https://tw.movies.yahoo.com/movie_intheaters.html?page=#{rand(1..3)}"))
    movies = doc.css('.release_movie_name')
    movies.each do |movie|
      movie_names << movie.css('a').first.text.split(' ').first
    end

    { text: '為您推薦以下電影(如果選項沒有可以直接輸入)', quick_replies: QuickReply.new(movie_names) }
  end

  def self.search(keyword, client)
    doc = Nokogiri::HTML(open(URI.encode("https://tw.movies.yahoo.com/moviesearch_result.html?keyword=#{keyword[0..100]}&type=movie&page=1")))
    m = doc.css('a').select{|m| m.text == '時刻表' }
    m = m.select{|m| m.attributes['href'] != nil }
    data = []
    if !m.first.nil?
      movie_name = doc.css('.release_movie_name').first.css('a').first.text
      url = m.first.attributes['href'].value
      doc = Nokogiri::HTML(open(url))

      doc.css('.area_timebox').each do |box|
        city_selector = box.css('.area_title')
        next if city_selector.text != client.city.name

        box.css('.area_time._c').first(5).compact.map do |where|
          times = where.css('.time .select').first(5).compact.map do |time|
            time.text
          end.join(', ')

          data << where.css('.adds').first.css('a').text + "(#{where.css('.tapR').text})" + "\n" + times if times.present?

          times == '' ? nil : times
        end

        break
      end

      data << "目前沒有可觀看的時間!!!" if data.compact.blank?
    else
      data << "查無此電影!!!"
    end

    { name: movie_name, data: data }
  end


  # def website(title)
  #   {
  #     type: 'template',
  #     payload: {
  #       template_type: 'button',
  #       text: name,
  #       buttons: [{
  #         type: 'web_url',
  #         url: url,
  #         title: title,
  #         webview_height_ratio: 'full',
  #         messenger_extensions: true,
  #         fallback_url: url,
  #       }],
  #     }
  #   }
  # end

  def website(title)
    {
      type: 'template',
      payload: {
        template_type: 'generic',
        elements: [{
          title: name,
          image_url: picture_url,
          subtitle: '簡介',
          default_action: {
            type: 'web_url',
            url: url,
            messenger_extensions: true,
            webview_height_ratio: 'full',
            fallback_url: url,
          },
          buttons: [{
            type: 'web_url',
            url: url,
            title: title,
          }],
        }]
      }
    }
  end

  def self.get_dates(movie_name)
    time_current = Time.current

    dates = (0..3).map{ |index| (time_current + index.days).date_weekday }

    { text: "你想看哪天的#{movie_name}？", quick_replies: QuickReply.new(dates) }
  end
end
