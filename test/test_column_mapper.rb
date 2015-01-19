require 'test_helper'

class TestColumnMapper < ActiveSupport::TestCase
  def test_sort_with_alias
    dobs = User.paginate(sort: 'birthday').to_a.map(&:date_of_birth)
    assert_equal dobs, dobs.sort
  end

  def test_sort_by_association
    teams = User.joins(:team).paginate(sort: 'team').map(&:team).map(&:name)
    assert_equal teams, teams.sort
  end

  def test_filter_with_alias
    users = User.filter(sex: 'f')
    assert User.where(gender: 'f').size, users.size
    users.each do |user|
      assert_equal 'f', user.gender
    end
  end

  def test_filter_by_association
    team = Team.first
    users = User.joins(:team).filter(team: team.name)
    assert_equal team.users.size, users.size
    users.each do |user|
      assert_equal team.name, user.team.name
    end
  end

  def test_undefined_method
    Yap.configure do |d|
      d.disable_warnings = true
    end
    assert_nothing_raised do
      Team.paginate(sort: 'name')
    end
    assert_nothing_raised do
      Team.paginate(filer: { 'name' => 'Moderator' } )
    end
  end
end