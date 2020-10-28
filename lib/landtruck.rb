require_relative "carrierwave/landscape/version"
require_relative "carrierwave/landscape/connection"
require_relative "carrierwave/landscape/storage"

class CarrierWave::Uploader::Base
  add_config :internal_url
  add_config :certificate
  add_config :public_host

  configure do |config|
    config.storage_engines[:landscape] = 'CarrierWave::Landscape::Storage'
  end
end