Gem::Specification.new do |s|
  s.name        = 'yap'
  s.version     = '0.2.0'
  s.date        = '2015-01-18'
  s.summary     = 'Yet another paginator for Ruby on Rails'
  s.description = 'Yet another paginator for Ruby on Rails adding a pagination and filtering interface to ActiveRecords.'
  s.authors     = ['Finn Glöe']
  s.email       = 'finn.gloee@1und1.de'
  s.files       = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  s.homepage    = 'http://rubygems.org/gems/yap'
  s.license     = 'GPL v2'

  s.required_ruby_version = '>= 2.1.0'
  
  s.add_runtime_dependency 'activerecord', '~> 4.1'
  s.add_development_dependency 'sqlite3', '~> 1.3'
end
