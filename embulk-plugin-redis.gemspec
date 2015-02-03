
Gem::Specification.new do |gem|
  gem.name          = "embulk-plugin-redis"
  gem.version       = "0.1.3"

  gem.summary       = %q{Embulk plugin for Redis}
  gem.description   = gem.summary
  gem.authors       = ["Mitsunori Komatsu"]
  gem.email         = ["komamitsu@gmail.com"]
  gem.license       = "Apache 2.0"
  gem.homepage      = "https://github.com/komamitsu/embulk-plugin-redis"

  gem.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc      = false

  gem.add_dependency 'redis', ['>= 3.0.5']
  gem.add_development_dependency 'bundler', ['~> 1.0']
  gem.add_development_dependency 'rake', ['>= 0.9.2']
end
