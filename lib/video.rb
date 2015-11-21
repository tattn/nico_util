class NicoUtil::Niconico
  def video video_id
    Video.new self, video_id
  end

  class Video
    def initialize owner, video_id
      @owner = owner
      @id = video_id
      flv_info
    end

    def flv_info
      return @flv_info if @flv_info

      @owner.check_logged_in!

      host = 'flapi.nicovideo.jp'
      path = "/api/getflv/#{@id}"

      response = Net::HTTP.new(host).start do |http|
        request = Net::HTTP::Get.new(path)
        request['cookie'] = @owner.cookie
        http.request(request)
      end

      if response.body[0..4] == 'error'
        raise InvalidIDError, 'Invalid video id'
      end

      flv_info = {}
      response.body.split('&').each do |st|
        stt = st.split('=')
        flv_info[stt[0].to_sym] = stt[1]
      end
      flv_info[:ms] = URI.unescape flv_info[:ms]

      @flv_info = flv_info
    end

    def comments limit_max = 1000
      return @comments if @comments && limit_max == 1000

      info = flv_info()
      uri = URI.parse info[:ms]

      response = Net::HTTP.new(uri.host).start do |http|
        request = Net::HTTP::Post.new(uri.path)
        thread_id = info[:thread_id]
        version = '20061206'   # 20090904
        language = '0'         # 1 or 2
        frk = 1                # 1:投稿者コメントあり
        term = '0-30:100,1000' # 30分の内、1分間最大100コメ、直近で1000コメ
        request.body = 
"<packet>
<thread thread='#{thread_id}' version='#{version}' scores='1' nicoru='1' language='#{language}' with_global='1'/>
<thread_leaves thread='#{thread_id}' scores='1' nicoru='1' language='0'>#{term}</thread_leaves>
<thread thread='#{thread_id}' version='#{version}' res_from='-#{limit_max}' fork='#{frk}'/>
</packet>"
        http.request(request)
      end

      comments = []
      xml = response.body.gsub('</chat>', "</chat>\n")
      xml.split("\n").each do |line|
        line.gsub! /<.*?>/, ''
        comments << line.force_encoding('utf-8') if line.length > 0
      end

      @comments = comments
    end
  end
end
