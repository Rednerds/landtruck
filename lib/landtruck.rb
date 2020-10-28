require "carrierwave/landscape/version"
require "carrierwave/landscape/connection"
require "carrierwave/landscape/storage"

class CarrierWave::Uploader::Base
  add_config :internal_url
  add_config :certificate
  add_config :public_host

  configure do |config|
    config.storage_engines[:landscape] = 'CarrierWave::Storage::Landscape'
  end
end