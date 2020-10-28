require "carrierwave/storage/abstract"

module CarrierWave
  module Landscape
    class Storage < CarrierWave::Storage::Abstract
      class << self
        def connection_cache
          @connection_cache ||= {}
        end

        def eager_load
          credentials = CarrierWave::Uploader::Base.fog_credentials
          if credentials.present?
            connection_cache[credentials] ||= Connection.new(credentials)
          end
        end
      end

      def store!(file)
        new_file = File.new(uploader, connection)
        new_file.store!(file)
        new_file
      end


      def retrieve!(token)
        File.new(uploader, connection, token)
      end

      def connection
        @connection ||= begin
          options = credentials = uploader.fog_credentials
          self.class.connection_cache[credentials] ||= Connection.new(options)
        end
      end

      class File
        def initialize(uploader, connection, identifier = nil)
          @uploader = uploader
          @connection = connection
          @identifier = nil
        end

        def store!(file)
          token = @connection.upload_file(file.to_file)
          @uploader.model.update_column uploader.mounted_as, token
        end

        def url(options = {})
          return if @identifier.nil?

          URI::HTTPS.build(host: connection.public_host, path: "/assets/#{@identifier}", query: URI.encode_www_form(options))
        end

        def read
          content
        end

        def filename
          metadata[:filename]
        end

        def extension
          File.extname(filename).delete('.')
        end

        def size
          metadata[:size]
        end

        def delete
          return false if @identifier.nil?

          @connection.destroy_file(@identifier)
        end

        private

        def content
          load_content if @content.nil?
          @content
        end

        def metadata
          @metadata ||= @connection.get_metadata(@identifier)
        end

        def load_content
          @content ||= @connection.download_file(@identifier)
        rescue Connection::FailedRequest
          nil
        end
      end
    end
  end
end