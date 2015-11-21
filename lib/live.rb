class NicoUtil::Niconico
  def live live_id
    Live.new self, live_id
  end

  class Live
    def initialize owner, live_id
      @owner = owner
      @id = live_id
    end

    def playerstatus
      return @playerstatus if @playerstatus

      host = 'live.nicovideo.jp'
      path = "/api/getplayerstatus?v=#{@id}"

      response = Net::HTTP.new(host).start do |http|
        request = Net::HTTP::Get.new(path)
        request['cookie'] = @owner.cookie
        http.request(request)
      end

      playerstatus = {}
      body = response.body.force_encoding('utf-8')
      doc = REXML::Document.new(body).elements['getplayerstatus']
      # stream = doc.elements['stream']
      # title = stream.elements['title'].text
      # desc = stream.elements['description'].text
      ms = doc.elements['ms']
      playerstatus[:addr] = ms.elements['addr'].text
      playerstatus[:port] = ms.elements['port'].text
      playerstatus[:thread_id] = ms.elements['thread'].text
      @playerstatus = playerstatus
    end

    def connect
      info = playerstatus()

      TCPSocket.open(info[:addr], info[:port].to_i) do |sock|
        ticket = "<thread thread=\"#{info[:thread_id]}\" version=\"20061206\" res_from=\"-1000\"/>\0"
        sock.write(ticket)
        # 最初の1回にいらないデータが来る
        p sock.gets("\0")
        while true
          stream = sock.gets("\0")
          if stream.index("\0") == stream.length - 1
            stream = stream[0..-2]
          end
          if stream
            # next if stream =~ /ifseetno/    # 一般会員を追い出した
            # next if stream =~ /panel clear/ # 運営が表示したパネルの削除
            # next if stream =~ /\/play/      # クルーズなどで動画を再生する
            if stream =~ /chat/
              stream = REXML::Document.new(stream).elements['chat']
              if stream
                if stream.text[0] == '/'
                  yield :command, stream.text
                else
                  yield :comment, stream.text
                end
              end
            elsif stream =~ /\/disconnect/
              yield :disconnect, nil
              break
            end
          end
        end
      end
    end

  end
end
