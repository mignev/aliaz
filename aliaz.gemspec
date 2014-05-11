# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aliaz/version'

Gem::Specification.new do |spec|
  spec.name          = "aliaz"
  spec.version       = Aliaz::VERSION
  spec.authors       = ["Marian Ignev"]
  spec.email         = ["m.ignev@gmail.com"]
  spec.summary       = %q{Extend every shell app with custom aliases.}
  spec.description   = <<-EOF
    This is a little program inspired from Git and its way to create aliases.
    So the idea here is just like in Git to add aliases and makes your live easier
    but for every shell app you use.
  EOF
  spec.homepage      = "http://github.com/mignev/aliaz"
  spec.license       = "MIT"

  spec.extensions = ["Rakefile"]

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
end
