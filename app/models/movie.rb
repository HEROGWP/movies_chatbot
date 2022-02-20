require 'open-uri' # warning: calling URI.open via Kernel#open is deprecated, call URI.open directly or use URI#open

class Movie < ApplicationRecord
  has_many :time_tables
  has_many :clients

  store :times

  def self.recommend
    # removed send when ruby upgrade to 2.7
    doc = Nokogiri::HTML(URI.send(:open,"https://tw.movies.yahoo.com/chart.html"))

    number_one = doc.css('.rank_list_box dd h2').text
    movie_names = doc.css('.rank_txt').map(&:text).first(10)

    { text: '為您推薦以下電影(如果選項沒有可以直接輸入)', quick_replies: QuickReply.new(movie_names.unshift(number_one)) }
  end

  def self.search(keyword, client)
    # removed send when ruby upgrade to 2.7
    doc = Nokogiri::HTML(URI.send(:open, URI.encode("https://tw.movies.yahoo.com/moviesearch_result.html?keyword=#{keyword[0..100]}&type=movie&page=1")))
    m = doc.css('a').select{|m| m.text == '時刻表' }
    m = m.select{|m| m.attributes['href'] != nil }
    data = []
    if !m.first.nil?
      movie_name = doc.css('.release_movie_name').first.css('a').first.text
      url = m.first.attributes['href'].value
      # removed send when ruby upgrade to 2.7
      doc = Nokogiri::HTML(URI.send(:open, url))

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

  def self.from_yahoo(yahoo_movie_id, movie_name)
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
      # removed send when ruby upgrade to 2.7
      doc = Nokogiri::HTML(URI.send(:open, info_url))
      picture_url = doc.css('.movie_intro_foto img').first.attributes['src'].value
      movie.update(times: data, url: info_url, picture_url: picture_url)
    end
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

  def get_dates
    time_current = Time.current

    dates = (0..3).map{ |index| (time_current + index.days).date_weekday }

    { text: "你想看哪天的#{name}？", quick_replies: QuickReply.new(dates) }
  end
end


# wget https://git.io/vpnsetup -O vpnsetup.sh && sudo \
# VPN_IPSEC_PSK='Pp27863047' \
# VPN_USER='herogwp' \
# VPN_PASSWORD='Pp27863047' \
# sh vpnsetup.sh
