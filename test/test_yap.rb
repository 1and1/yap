require 'test_helper'

class TestYap < ActiveSupport::TestCase
  def test_default_parameters
    page = User.paginate

    assert_equal User.first, page.first              # default page: 1
    assert_equal Yap::DEFAULTS.per_page, page.size
    assert page.first.id < page.second.id            # default sort/direction: id/asc
  end

  def test_page
    assert_equal User.offset(Yap::DEFAULTS.per_page).first, User.paginate(page: 2).first
  end

  def test_per_page
    assert_equal 15, User.paginate(per_page: 15).size
  end

  def test_sort
    page = User.paginate(sort: :name)
    assert page.first.name < page.second.name
  end

  def test_direction
    page = User.paginate(direction: :desc)
    assert page.second.id < page.first.id
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
    assert page.second.name < page.first.name
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

  def test_chaining
    page = User.where.not(date_of_birth: nil).paginate
    assert_not_empty page
    page.each do |user|
      assert_not_nil user.date_of_birth
    end
  end

  def test_last_page
    params = { per_page: 3 }
    # last page should have 3 or less users
    assert User.paginate(params.merge(page: User.last_page(params))).size <= params[:per_page]

    # the page beyond last page should be empty
    assert_empty User.paginate(params.merge(page: User.last_page(params)+1))
  end
end