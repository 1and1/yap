require 'simplecov'
SimpleCov.start

require 'active_record'
require 'minitest/autorun'
require 'pp'
require 'yap'
require 'yap/exceptions'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

require './db/schema'
require './db/models'

ActiveSupport.test_order = :random if ActiveSupport.respond_to? :test_order=

Team.create!(name: 'Operator')
Team.create!(name: 'Moderator')
Team.create!(name: 'User')

1.upto(15).each do |i|
  User.create!(
          name: (('a'..'z').to_a + ('A'..'Z').to_a).sample(12).join,
          date_of_birth: Date.today - (10 + rand(20)).years - rand(12).months - rand(365).days,
          gender: i <= 7 ? 'f' : %w(f m).sample,
          team: (Team.all.to_a << nil).sample
  )
end
