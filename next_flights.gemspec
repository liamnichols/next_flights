
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "next_flights/version"

Gem::Specification.new do |spec|
  spec.name          = "next_flights"
  spec.version       = NextFlights::VERSION
  spec.authors       = ["Liam Nichols"]
  spec.email         = ["liam.nichols.ln@gmail.com"]

  spec.summary       = ""
  spec.description   = ""
  spec.homepage      = "https://github.com/liamnichols/next_flights"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "dotenv", "~> 3.1"
  spec.add_development_dependency "pry", "~> 0.14"

  spec.add_dependency "oauth2", "~> 2.0"
  spec.add_dependency "json", "~> 2.7"
end
