module NicoUtil
  class Service
    def self.search service, query, params={}
      params[:q] = query
      params[:targets] = 'title,description,tags' unless params.key? :targets
      params[:fields] = 'contentId,title,description,tags' unless params.key? :fields
      params[:_sort] = '-viewCounter' unless params.key? :_sort
      params[:_context] = 'aniguide' unless params.key? :_context
      params = URI.encode_www_form(params)

      host = 'api.search.nicovideo.jp'
      path = "/api/v2/#{service}/contents/search?#{params}"

      response = Net::HTTP.new(host).start do |http|
        request = Net::HTTP::Get.new(path)
        http.request(request)
      end

      JSON.parse response.body, symbolize_names: true
    end
  end
end
