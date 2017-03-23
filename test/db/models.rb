require 'active_record'
require 'yap'

class User < ActiveRecord::Base
  include Yap
  belongs_to :team

  api_aliases 'team' => 'teams.name',
      'birthday' => 'date_of_birth',
      'sex' => 'gender',
      'last_name' => 'name'
end

class Team < ActiveRecord::Base
  include Yap
  has_many :users
end
