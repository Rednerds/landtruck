require "http"
require "connection_pool"
require "jwt"
require "mimemagic"

module Landscape
  class Connection
    class InvalidRequest < StandardError; end
    class FailedRequest < StandardError; end

    TOKEN_EXPIRATION = 60
    TIMEOUT          = 60
    READ_TIMEOUT     = 60
    WRITE_TIMEOUT    = 60
    CONNECTION_POOL  = 5
    CONNECT_TIMEOUT  = 2

    attr_reader :internal_url, :certificate, :public_host

    def initialize(internal_url:, certificate:, public_host:)
      @internal_url = internal_url
      @certificate = certificate
      @public_host = public_host
    end

    def upload_file(file, filename)
      raise InvalidRequest if file.nil?

      response = connection.with do |c|
        c.post("#{internal_url}/upload/assets", form: { file: HTTP::FormData::File.new(file, filename: filename) })
      end
      raise FailedRequest.new(json_response(response)) unless response.status.success?
      json_response(response)["token"]
    end

    def destroy_file(token)
      raise InvalidRequest if token.nil?

      response = connection.with do |c|
        c.delete("#{internal_url}/upload/assets/#{token}")
      end
      raise FailedRequest.new(json_response(response)) unless response.status.success?
      true
    end

    def update_file(token, file)
      raise InvalidRequest if file.nil? || token.nil?

      response = connection.with do |c|
        c.put("#{internal_url}/upload/assets/#{token}", form: { file: HTTP::FormData::File.new(file), type: identify_type(file) })
      end
      raise FailedRequest.new(json_response(response)) unless response.status.success?
      token
    end

    def get_metadata(token)
      raise InvalidRequest if token.nil?

      response = connection.with do |c|
        c.get("#{internal_url}/assets/#{token}/metadata")
      end

      json_response(response).symbolize_keys
    end

    private

    def json_response(response)
      JSON.parse(response.to_s)
    end

    def connection
      @connection ||= ConnectionPool.new(size: CONNECTION_POOL, timeout: TIMEOUT) do
        HTTP.auth(authorization)
            .use(:auto_inflate)
            .accept(:json)
            .nodelay
            .timeout(connect: CONNECT_TIMEOUT, read: READ_TIMEOUT, write: WRITE_TIMEOUT)
      end
    end

    def authorization
      JWT.encode({ iss: Rails.application.class.name }, private_key, "PS256")
    end

    def private_key
      OpenSSL::PKey::RSA.new(certificate)
    end
  end
end
