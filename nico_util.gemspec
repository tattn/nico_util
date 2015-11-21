# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nico_util/version'

Gem::Specification.new do |spec|
  spec.name          = "nico_util"
  spec.version       = NicoUtil::VERSION
  spec.authors       = ["Tatsuya Tanaka (tattn)"]
  spec.email         = ["tatsuyars@yahoo.co.jp"]

  spec.summary       = %q{Utility APIs for niconico}
  spec.description   = %q{Utility APIs for niconico}
  spec.homepage      = "https://github.com/tattn/nico_util"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
