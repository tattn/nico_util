require 'json'

class NicoUtil::Niconico
  def illust illust_id
    Illust.new self, illust_id
  end

  class Illust
    def initialize owner, illust_id
      @owner = owner
      if illust_id[0..1] == 'im'
        @id = illust_id[2..-1] 
      else
        @id = illust_id
      end
    end

    def comments
      return @comments if @comments

      host = 'seiga.nicovideo.jp'
      path = "/ajax/illust/comment/list?id=#{@id}&mode=all"

      response = Net::HTTP.new(host).start do |http|
        request = Net::HTTP::Get.new(path)
        request['cookie'] = @owner.cookie
        http.request(request)
      end

      comments = []
      body = JSON.parse response.body.force_encoding('utf-8')

      if body.key? 'errors'
        raise InvalidIDError, body["errors"]
      end

      body["comment_list"].each do |comment|
        comments << comment["text"]
      end

      @comments = comments
    end

    def image_url
      return @image_url if @image_url

      host = 'seiga.nicovideo.jp'
      path = "/image/source?id=#{@id}"

      response = Net::HTTP.new(host).start do |http|
        request = Net::HTTP::Get.new(path)
        request['cookie'] = @owner.cookie
        http.request(request)
      end

      case response
      when Net::HTTPRedirection
        url = response['location']
        @image_url = url.gsub 'lohas.nicoseiga.jp/o', 'lohas.nicoseiga.jp/priv'
      end

      @image_url
    end

    def download
      Net::HTTP.get_response(URI.parse(image_url)).body
    end

    def save filename
      #TODO: identify filetype [png, jpg, gif]
      File.write(filename, download)
    end
  end
end
