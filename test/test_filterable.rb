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

  def test_date_match
    dob = User.first.date_of_birth
    users = User.filter(date_of_birth: to_api_date(dob))
    assert_equal User.where(date_of_birth: dob).size, users.size
    users.each do |user|
      assert_equal dob, user.date_of_birth
    end
  end

  def test_range_match
    startdate = Date.today - 30.years
    enddate = Date.today - 20.years
    users = User.filter(date_of_birth: '%s..%s' % [to_api_date(startdate), to_api_date(enddate)])
    assert_equal User.where(date_of_birth: startdate..enddate).size, users.size
    users.each do |user|
      assert_includes startdate..enddate, user.date_of_birth
    end
  end

  def to_api_date(date)
    date.strftime('%Y-%m-%d')
  end
  private :to_api_date

  def test_greater_match
    users = User.filter({ id: '>10' })
    assert_equal User.where('id > 10').size, users.size
    users.each do |user|
      assert user.id > 10
    end
  end

  def test_less_match
    users = User.filter({ id: '<10' })
    assert_equal User.where('id < 10').size, users.size
    users.each do |user|
      assert user.id < 10
    end
  end

  def test_greater_or_equal_match
    users = User.filter({ id: '>=10' })
    assert_equal User.where('id >= 10').size, users.size
    users.each do |user|
      assert user.id >= 10
    end
  end

  def test_less_or_equal_match
    users = User.filter({ id: '<=10' })
    assert_equal User.where('id <= 10').size, users.size
    users.each do |user|
      assert user.id <= 10
    end
  end

  def test_not_with_comparison_operator
    users = User.filter({ id: '!<=10' })
    assert_equal User.where.not('id <= 10').size, users.size
    users.each do |user|
      assert_not user.id <= 10
    end
  end

  def test_comparison_with_date_should_fail
    ex = assert_raises Yap::FilterError do
      User.filter({ date_of_birth: "<=#{to_api_date(Date.today)}" })
    end
    assert_match 'float value', ex.message
  end

  def test_incorrect_parameters
    ex = assert_raises Yap::FilterError do
      User.filter(not_a_column: 'null')
    end
    assert_match 'not_a_column', ex.message
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

  def test_combined_paginate
    team = Team.first
    per_page = 3
    users = User.paginate(per_page: per_page, filter: { team_id: team.id })

    # Size is either restricted by pagination or filter
    assert users.size <= per_page
    assert users.size <= team.users.size
    assert_includes [per_page, team.users.size], users.size
    users.each do |user|
      assert_equal team.id, user.team_id
    end
  end
end
