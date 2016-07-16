require 'active_record'
require 'yap'

class User < ActiveRecord::Base
  include Yap
  belongs_to :team

  COLUMN_MAP = {
    'team' => 'teams.name',
    'birthday' => 'date_of_birth',
    'sex' => 'gender'
  }.freeze

  def self.map_name_to_column(name)
    COLUMN_MAP[name]
  end
end

class Team < ActiveRecord::Base
  include Yap
  has_many :users
end
