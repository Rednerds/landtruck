require "down/http"

module Landscape
  class Storage
    attr_reader :internal_url, :certificate, :public_host

    def initialize(internal_url:, certificate:, public_host:)
      @internal_url = internal_url
      @certificate = certificate
      @public_host = public_host
    end

    def upload(io, id, shrine_metadata: {}, **options)
      token = connection.upload_file(io.to_io)
      id.replace(token)
      shrine_metadata.merge!(metadata(id).transform_keys(&:to_s))
    end

    def open(id, **options)
      Down::Http.open(url(id))
    end

    def exists?(id)
      !!metadata(id)
    end

    def delete(id)
      connection.destroy_file(id)
    end

    def url(id, options = {})
      return if id.nil?

      host, port = public_host.split(":")
      query = options.empty? ? nil : URI.encode_www_form(options)
      URI::HTTPS.build(host: host, port: port, path: "/assets/#{id}", query: query).to_s
    end

    def update(id, **options)
      shrine_metadata.merge!(metadata(id))
    end

    def metadata(id)
      connection.get_metadata(id).transform_keys(&:to_s)
    end

    private

    def connection
      @connection ||= Connection.new(internal_url: internal_url, certificate: certificate, public_host: public_host)
    end
  end
end