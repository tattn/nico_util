module NicoUtil
  class Niconico
    def book book_id
      Book.new self, book_id
    end
  end

  class Book
    def initialize owner, book_id
      @owner = owner
      @id = book_id
    end

    def url
      "http://seiga.nicovideo.jp/watch/#{@id}"
    end

    def self.search query, params={}
      Service.search 'book', query, params
    end

  end
end
