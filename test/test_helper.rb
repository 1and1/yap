require 'active_record'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

require './db/schema'
require './db/models'

require 'yap'
