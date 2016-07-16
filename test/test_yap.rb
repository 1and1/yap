require 'test_helper'

class TestYap < ActiveSupport::TestCase
  def setup
    @saved_defaults = Yap::DEFAULTS.dup
  end

  def test_configuration
    Yap.configure do |d|
      d.page = 2
      d.per_page = 7
      d.sort = :name
    end

    conf = Yap.configuration

    assert_equal 2, conf.page
    assert_equal 7, conf.per_page
    assert_equal :name, conf.sort
  ensure
    restore_defaults
  end

  def test_default_parameters
    page = User.paginate

    assert_equal User.first, page.first              # default page: 1
    assert_equal Yap::DEFAULTS.per_page, page.size
    assert page.first.id < page.second.id            # default sort/direction: id/asc
  end

  def test_valid_default_parameters
    Yap.configure do |d|
      d.page = 1
      d.per_page = 5
      d.sort = :id
      d.direction = :desc
    end

    assert_nothing_raised do
      User.paginate
    end
  ensure
    restore_defaults
  end

  def test_invalid_default_parameters
    Yap.configure do |d|
      d.page = 'invalid_page'
      d.per_page = 'invalid_per_page'
      d.sort = 'invalid_sort'
      d.direction = 'invalid_direction'
    end

    valid_params = {
        page: 1,
        per_page: 5,
        sort: :id,
        direction: :desc
    }

    ex = assert_raises Yap::PaginationError do
      User.paginate(valid_params.except(:page))
    end
    assert_match 'invalid_page', ex.message

    ex = assert_raises Yap::PaginationError do
      User.paginate(valid_params.except(:per_page))
    end
    assert_match 'invalid_per_page', ex.message

    ex = assert_raises Yap::PaginationError do
      User.paginate(valid_params.except(:sort))
    end
    assert_match 'invalid_sort', ex.message

    ex = assert_raises Yap::PaginationError do
      User.paginate(valid_params.except(:direction))
    end
    assert_match 'invalid_direction', ex.message
  ensure
    restore_defaults
  end

  def restore_defaults
    Yap::DEFAULTS.each_with_index do |d, i|
      Yap::DEFAULTS[i] = @saved_defaults[i]
    end
  end
  private :restore_defaults

  def test_page
    assert_equal User.offset(Yap::DEFAULTS.per_page).first, User.paginate(page: 2).first
  end

  def test_per_page
    assert_equal 15, User.paginate(per_page: 15).size
  end

  def test_sort
    page = User.paginate(sort: :name).map(&:name)
    assert_equal page, page.sort
  end

  def test_direction
    page = User.paginate(direction: :desc).map(&:id)
    assert_equal page, page.sort.reverse
  end

  def test_parameters_as_string
    page = User.paginate(
        page: '2',
        per_page: '5',
        sort: 'name',
        direction: 'desc'
    )
    assert_equal User.order(name: :desc).offset(5).first, page.first
    assert_equal 5, page.size
    assert_equal page.map(&:name), page.map(&:name).sort.reverse
  end

  def test_incorrect_parameters
    assert_raises Yap::PaginationError do
      User.paginate(page: 'not_a_number')
    end

    assert_raises Yap::PaginationError do
      User.paginate(per_page: 'not_a_number')
    end

    assert_raises Yap::PaginationError do
      User.paginate(sort: 'not_a_column')
    end

    assert_raises Yap::PaginationError do
      User.paginate(direction: 'not_a_direction')
    end
  end

  def test_page_out_of_range
    assert_raises Yap::PaginationError do
      User.paginate(page: '-1')
    end
    assert_raises Yap::PaginationError do
      User.paginate(page: '0')
    end

    assert_raises Yap::PaginationError do
      User.paginate(per_page: '-1')
    end
    assert_raises Yap::PaginationError do
      User.paginate(per_page: '0')
    end
  end

  def test_empty_page
    assert_empty User.paginate(page: 2, per_page: 1000)
  end

  def test_hard_limit
    Yap.configure do |d|
      d.hard_limit = 10
    end

    assert_raises Yap::PaginationError do
      User.paginate(per_page: 11)
    end
    assert_raises Yap::PaginationError do
      User.paginate(per_page: 100)
    end

    assert_nothing_raised do
      User.paginate(per_page: 10)
    end
    assert_nothing_raised do
      User.paginate(per_page: 1)
    end

    restore_defaults
  end

  def test_chaining
    page = User.where.not(date_of_birth: nil).paginate
    assert_not_empty page
    page.each do |user|
      assert_not_nil user.date_of_birth
    end
  end

  def test_last_page
    params = { per_page: 4 }

    # ensure last_page exists
    last = User.paginate(params).last_page

    # last page should have less than 3 users
    assert User.paginate(params.merge(page: last)).size < params[:per_page]

    # the page beyond last page should be empty
    assert_empty User.paginate(params.merge(page: last+1))
  end

  def test_range
    params = {
        page: 2,
        per_page: 3,
        filter: {
          gender: 'f'
        }
    }

    range = User.paginate(params).range(true)
    total = User.where(params[:filter]).count
    assert_equal total, range[:total]

    # :from must be first of :page
    assert_equal 4, range[:from]

    # :to must be either :total or last of :page
    assert_equal 6, range[:to]
  end

  def test_range_no_total
    assert_not User.paginate.range.key? :total
  end

  def test_sort_by_csl_of_columns
    sort = {
        team: :desc,
        date_of_birth: :asc
    }
    params = {
        sort: sort.keys.join(','),
        direction: sort.values.join(','),
        per_page: 100
    }

    users = User.joins(:team).paginate(params)
    assert_sorted_by_team_and_name users
  end

  def test_sort_by_array
    sort = {
        team: :desc,
        date_of_birth: :asc
    }
    params = {
        sort: sort.keys,
        direction: sort.values,
        per_page: 100
    }

    users = User.joins(:team).paginate(params)
    assert_sorted_by_team_and_name users
  end

  def test_sort_by_array_missing_a_direction
    sort = {
        team: :desc,
        date_of_birth: :asc
    }
    params = {
        sort: sort.keys,
        direction: sort.values.first(1),
        per_page: 100
    }

    users = User.joins(:team).paginate(params)
    assert_sorted_by_team_and_name users
  end

  def test_sort_by_array_missing_all_directions
    params = {
        sort: [:team, :date_of_birth],
        per_page: 100
    }

    users = User.joins(:team).paginate(params)
    assert_not_empty users
    assert_equal users.map { |u| u.team.name }, users.map { |u| u.team.name }.sort
  end

  def test_sort_by_hash
    sort = {
        team: :desc,
        date_of_birth: :asc
    }
    params = {
        sort: sort,
        per_page: 100
    }

    users = User.joins(:team).paginate(params)
    assert_sorted_by_team_and_name users
  end

  def assert_sorted_by_team_and_name(users)
    assert_not_empty users

    assert_equal users.map { |u| u.team.name }, users.map { |u| u.team.name }.sort.reverse

    users.map { |u| u.team.name }.uniq.each do |f|
      filtered = users.select { |u| u.team.name == f }
      assert_equal filtered.map(&:date_of_birth), filtered.map(&:date_of_birth).sort
    end
  end
  private :assert_sorted_by_team_and_name
end
