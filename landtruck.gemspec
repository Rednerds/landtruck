require_relative 'lib/landscape/version'

Gem::Specification.new do |spec|
  spec.name          = "landtruck"
  spec.version       = Landscape::VERSION
  spec.authors       = ["Boris Gushin"]
  spec.email         = ["me@nile.ninja"]

  spec.summary       = %q{Carrierwave adapter to interact with Landfill service}
  spec.homepage      = "http://github.com/rednerds/landtruck"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "http", ">= 4.0"
  spec.add_dependency "jwt", "~> 2"
  spec.add_dependency "connection_pool"
  spec.add_dependency "down", "~> 5.0"
  spec.add_dependency "mimemagic"
  spec.add_development_dependency "pry"
end
