# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "personal.blog"
  spec.version       = "0.1.0"
  spec.authors       = ["th3iedkid"]
  spec.email         = ["th3iedkid@users.noreply.github.com"]

  spec.summary       = %q{sample}
  spec.homepage      = "http://example.com"
  spec.license       = "ASLv2"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(_layouts|_includes|_sass|LICENSE|README)/i}) }

  spec.add_development_dependency "jekyll", "~> 3.2"
  spec.add_development_dependency "bundler", "~> 1.7.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
