# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bbiff/version'

Gem::Specification.new do |spec|
  spec.name          = "bbiff"
  spec.version       = Bbiff::VERSION
  spec.authors       = ["Yoteichi"]
  spec.email         = ["plonk@piano.email.ne.jp"]

  spec.summary       = %q{notifies new post arrival on the Shitaraba BBS.}
  spec.homepage      = "https://github.com/plonk/bbiff"
  spec.licenses      = "GPL-2"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   << 'bbiff'
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency "unicode-display_width", "~>1.4.1"
end
