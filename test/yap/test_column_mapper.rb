require 'test_helper'

class TestColumnMapper < ActiveSupport::TestCase
  def fake_model
    Class.new(ActiveRecord::Base) do
      self.table_name = 'teams'
      include Yap
    end
  end

  def test_api_aliases_with_hash
    fake = fake_model
    fake.api_aliases foo: :bar, 'bar' => 'baz'

    assert_equal 'bar', fake.map_column('foo')
    assert_equal 'baz', fake.map_column('bar')
  end

  def test_api_aliases_with_block
    fake = fake_model
    fake.api_aliases do |a|
      a.camelize
    end

    assert_equal 'FooBar', fake.map_column('foo_bar')
  end

  def test_api_aliases_with_multiple_arguments
    fake = fake_model

    ex = assert_raises ArgumentError do
      fake.api_aliases foo: :bar do |a|
        a.camelize
      end
    end
    assert_equal 'Only one of the following allowed: Hash of aliases or block.', ex.message
  end

  def test_api_aliases_with_no_arguments
    fake = fake_model

    assert_nothing_raised do
      fake.api_aliases
    end
  end

  def test_api_aliases_multiple_invocations
    fake = fake_model
    fake.api_aliases foo: :bar, 'bar' => 'baz'

    ex = assert_raises do
      fake.api_aliases do |a|
        a.camelize
      end
    end
    assert_equal 'Aliases already defined. Make sure to invoke api_aliases only once.', ex.message
  end

  def test_api_aliases_with_wrong_argument
    fake = fake_model

    ex = assert_raises do
      fake.api_aliases [:foobar]
    end
    assert_equal 'Expected first argument to be a Hash, got Array.', ex.message
  end

  def test_sort_with_alias
    dobs = User.paginate(sort: 'birthday').to_a.map(&:date_of_birth)
    assert_equal dobs, dobs.sort
  end

  def test_sort_by_association
    teams = User.joins(:team).paginate(sort: 'team').map(&:team).map(&:name)
    assert_equal teams, teams.sort
  end

  def test_filter_with_alias
    users = User.filtered(sex: 'f')
    assert User.where(gender: 'f').size, users.size
    users.each do |user|
      assert_equal 'f', user.gender
    end
  end

  def test_filter_by_association
    team = Team.first
    users = User.joins(:team).filtered(team: team.name)
    assert_equal team.users.size, users.size
    users.each do |user|
      assert_equal team.name, user.team.name
    end
  end

  def test_undefined_method
    assert_nothing_raised do
      Team.paginate(sort: 'name')
    end
    assert_nothing_raised do
      Team.paginate(filer: { 'name' => 'Moderator' } )
    end
  end

  def test_alias_vs_real_column
    assert_equal 'name', User.map_column('last_name')
  end
end