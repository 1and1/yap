require './lib/yap/version'

Gem::Specification.new do |s|
  s.name        = 'yap'
  s.version     = Yap::VERSION
  s.author      = 'Finn Glöe'
  s.email       = 'finn.gloee@1und1.de'
  s.summary     = 'Yet another paginator for Ruby on Rails'
  s.description = 'Yet another paginator for Ruby on Rails adding pagination and filtering interface to ActiveRecords.'
  s.files       = Dir.glob('lib/**/*') + %w[LICENSE README.md]
  s.homepage    = 'https://github.com/1and1/yap'
  s.license     = 'GPL v2'

  s.required_ruby_version = '>= 1.9.3'

  s.add_runtime_dependency 'activerecord', '>= 4.2', '< 7'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'rake', '~> 11.1'
end
