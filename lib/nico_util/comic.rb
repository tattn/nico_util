module NicoUtil
  class Niconico
    def comic live_id
      Comic.new self, live_id
    end
  end

  class Comic
    def initialize owner, comic_id
      @owner = owner
      @id = comic_id
    end

    def url
      "http://seiga.nicovideo.jp/comic/#{@id}"
    end

    def self.search query, params={}
      Service.search 'manga', query, params
    end

  end
end
