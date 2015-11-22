module NicoUtil
  class Niconico
    def channel channel_id
      Channel.new self, channel_id
    end
  end

  class Channel
    def initialize owner, channel_id
      @owner = owner
      @id = channel_id
    end

    def url
      "http://ch.nicovideo.jp/#{@id}"
    end

    def self.search query, params={}
      params[:_sort] = '-startTime' unless params.key? :_sort
      Service.search 'channel', query, params
    end

  end
end
