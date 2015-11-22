module NicoUtil
  class Niconico
    def news news_id
      News.new self, news_id
    end
  end

  class News
    def initialize owner, news_id
      @owner = owner
      @id = news_id
    end

    def url
      "http://news.nicovideo.jp/watch/#{@id}"
    end

    def self.search query, params={}
      params[:targets] = 'title,tags' unless params.key? :targets
      Service.search 'news', query, params
    end

  end
end
