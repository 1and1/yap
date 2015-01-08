Gem::Specification.new do |s|
  s.name        = 'yap'
  s.version     = '0.1.1'
  s.date        = '2015-01-08'
  s.summary     = 'Yet another paginator for Ruby on Rails'
  s.description = 'Yet another paginator for Ruby on Rails, which adds a paginate scope to your ActiveRecords.'
  s.authors     = ['Finn Glöe']
  s.email       = 'finn.gloee@1und1.de'
  s.files       = ['lib/yap.rb']
  s.homepage    = 'http://rubygems.org/gems/yap'
  s.license     = 'GPL v2'

  s.required_ruby_version = '>= 2.1.0'
  
  s.add_runtime_dependency 'activerecord', '~> 4.1'
  s.add_development_dependency 'sqlite3', '~> 1.3'
end
