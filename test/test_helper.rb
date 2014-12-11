require 'active_record'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

require './db/schema'
require './db/models'

require 'yap'

1.upto(15).each do
  User.create!(
          name: (('a'..'z').to_a + ('A'..'Z').to_a ).shuffle[0,12].join,
          date_of_birth: Time.now - (10 + rand(20)).years - rand(12).months - rand(365).days
  )
end
