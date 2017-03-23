require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
end

default_tasks = [:test]

if RUBY_VERSION >= '2.0' && Gem::Specification.find_all_by_name('rubocop').any?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks << :rubocop
end

desc 'Run tests and rubocop'
task default: default_tasks
