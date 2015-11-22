require 'uri'
require 'net/http'
require 'openssl'
require 'rexml/document'

module NicoUtil
  def self.login email, pass
    Niconico.new email, pass
  end

  class Niconico
    class AuthenticationError < StandardError; end
    class InvalidIDError < StandardError; end

    def initialize email, pass
      @cookie = nil
      @email = email
      @pass = pass

      login
    end

    def cookie
      login if @cookie == nil
      @cookie
    end

    def login
      host = 'secure.nicovideo.jp'
      path = '/secure/login?site=niconico'
      body = "mail=#{@email}&password=#{@pass}"

      https = Net::HTTP.new host, 443
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = https.start do |https|
        https.post path, body
      end

      @cookie = nil
      response['set-cookie'].split('; ').each do |st|
        if idx=st.index('user_session_')
          @cookie = "user_session=#{st[idx..-1]}"
          break
        end
      end

      unless @cookie
        puts 'Invalid email or password'
      end
    end

    def logged_in?
      @cookie != nil
    end

    def check_logged_in!
      unless logged_in?
        raise AuthenticationError, "You are not authorized..."
      end
    end

  end
end

require_relative 'nico_util/service.rb'
require_relative 'nico_util/video.rb'
require_relative 'nico_util/live.rb'
require_relative 'nico_util/illust.rb'
require_relative 'nico_util/comic.rb'
require_relative 'nico_util/book.rb'
require_relative 'nico_util/channel.rb'
require_relative 'nico_util/blog.rb'
require_relative 'nico_util/news.rb'

p NicoUtil::Book.search 'らき☆すた'
