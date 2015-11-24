require 'json'

module NicoUtil
  class Niconico
    def illust illust_id
      Illust.new self, illust_id
    end
  end

  class Illust
    class InvalidImageError < StandardError; end

    def initialize owner, illust_id
      @owner = owner
      if illust_id[0..1] == 'im'
        @id = illust_id[2..-1] 
      else
        @id = illust_id
      end
    end

    def url
      "http://seiga.nicovideo.jp/seiga/im#{@id}"
    end
    
    def self.search query, params={}
      Service.search 'illust', query, params
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
      data = download
      check = check_image data
      if check[1] == :damaged 
        raise InvalidImageError, "Downloaded image was broken. The filetype was #{check[0]}."
      elsif check[0] == :unknown
        raise InvalidImageError, "The filetype of downloaded image was unknown."
      end
      filename = Pathname(filename).sub_ext('.'+check[0].to_s).to_s
      File.binwrite(filename, data)
    end

    private

    def check_image data
      result = [ :unknown, :clean ]  
      begin
        header = data[0, 8]
        footer = data[data.length-12, 12]
      rescue
        result[1] = :damaged
        return result
      end

      if header[0,2].unpack("H*") == [ "ffd8" ]
        result[0] = :jpg
        result[1] = :damaged unless footer[-2,2].unpack("H*") == [ "ffd9" ]
      elsif header[0,3].unpack("A*") == [ "GIF" ]
        result[0] = :gif
        result[1] = :damaged unless footer[-1,1].unpack("H*") == [ "3b" ]
      elsif header[0,8].unpack("H*") == [ "89504e470d0a1a0a" ]
        result[0] = :png
        result[1] = :damaged unless footer[-12,12].unpack("H*") == [ "0000000049454e44ae426082" ]
      end
      result
    end
  end
end
