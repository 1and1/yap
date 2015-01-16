require 'active_record'
require 'minitest/autorun'
require 'pp'
require 'yap'
require 'yap/exceptions'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

require './db/schema'
require './db/models'

ActiveSupport.test_order = :random

Team.create!(name: 'Operator')
Team.create!(name: 'Moderator')
Team.create!(name: 'User')

1.upto(15).each do
  User.create!(
          name: (('a'..'z').to_a + ('A'..'Z').to_a ).shuffle[0,12].join,
          date_of_birth: Time.now - (10 + rand(20)).years - rand(12).months - rand(365).days,
          gender: %w(m f).sample,
          team: (Team.all << nil).sample
  )
end
