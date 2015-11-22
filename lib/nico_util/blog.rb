module NicoUtil
  class Niconico
    def blog blog_id
      Blog.new self, blog_id
    end
  end

  class Blog
    def initialize owner, blog_id
      @owner = owner
      @id = blog_id
    end

    def url
      return @url if @url
      response = Net::HTTP.get_response(URI.parse("http://nico.ms/#{@id}"))
      case response
      when Net::HTTPRedirection
        @url = response['location']
      end
      @url
    end

    def self.search query, params={}
      #TODO: enable to search all blogs
      Service.search 'channelarticle', query, params
    end

  end
end
