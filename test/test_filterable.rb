require 'test_helper'

class FilterableTest < ActiveSupport::TestCase
  def test_single_condition
    team = Team.first
    users = User.filter(team_id: team.id)
    assert_equal team.users.size, users.size
    users.each do |user|
      assert_equal team.id, user.team_id
    end
  end

  def test_multiple_values
    teams = Team.take(2)
    users = User.filter(team_id: teams.map(&:id).join(','))
    assert_equal teams.map(&:users).map(&:size).sum, users.size
    users.each do |user|
      assert teams.map(&:id).include? user.team_id
    end
  end

  def test_multiple_conditions
    team = Team.first
    users = User.filter(team_id: team.id, gender: 'm')
    assert_equal team.users.select { |u| u.gender == 'm' }.size, users.size
    users.each do |user|
      assert_equal 'm', user.gender
      assert_equal team.id, user.team_id
    end
  end

  def test_negative_match
    users = User.filter(gender: '!m')
    assert User.where(gender: 'f').size, users.size
    users.each do |user|
      assert_not_equal 'm', user.gender
    end
  end

  def test_null_match
    users = User.filter(team_id: 'null')
    assert_equal User.where(team: nil).size, users.size
    users.each do |user|
      assert_nil user.team_id
    end
  end

  def test_incorrect_parameters
    assert_raises Yap::FilterError do
      User.filter(not_a_column: 'null')
    end
  end

  def test_chaining
    users = User.filter(gender: 'f').limit(5)
    assert 5 >= users.size
    users.each do |user|
      assert_equal 'f', user.gender
    end
  end

  def test_empty_filter
    users = User.filter(nil)
    assert_equal User.count, users.size

    users = User.filter
    assert_equal User.count, users.size
  end
end
