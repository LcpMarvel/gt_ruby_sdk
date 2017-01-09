require 'faraday'
require 'json'

module GtRubySdk
  class RemoteServer
    REQUEST_URL = 'http://api.geetest.com/'.freeze
    REGISTER_PATH = '/register.php'.freeze
    VALIDATE_PATH = '/validate.php'.freeze

    CONNECTION_TIMEOUT = 1
    READ_TIMEOUT = 1

    class << self
      def register(captcha_id, user_id)
        conn = Faraday.new(url: REQUEST_URL) do |faraday|
          faraday.request :url_encoded
          faraday.response :raise_error
          faraday.adapter Faraday.default_adapter
        end

        params = { gt: captcha_id }.tap do |query|
          query[:user_id] = user_id if user_id.present?
        end

        request_response = conn.get do |req|
          req.url REGISTER_PATH, params
          req.options.timeout = READ_TIMEOUT
          req.options.open_timeout = CONNECTION_TIMEOUT
        end

        request_response.body
      end

      def validate(data)
        request_response = request_connection.post do |req|
          req.url VALIDATE_PATH
          req.options.timeout = READ_TIMEOUT
          req.options.open_timeout = CONNECTION_TIMEOUT

          req.body = data
        end

        request_response.body
      end

      def request_connection
        Faraday.new(url: REQUEST_URL) do |faraday|
          faraday.request :url_encoded
          faraday.response :raise_error
          faraday.adapter Faraday.default_adapter
        end
      end
    end
  end
end
