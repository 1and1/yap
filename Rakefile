require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

default_tasks = [:test]

if RUBY_VERSION >= '2.0'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks << :rubocop
end

desc 'Run tests and rubocop'
task default: default_tasks
