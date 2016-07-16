[![Build Status](https://travis-ci.org/1and1/yap.svg?branch=master)](https://travis-ci.org/1and1/yap)

Yet another paginator for Ruby on Rails, which adds a `paginate` scope to your ActiveRecords.

## Setup

Include `Yap` into your models to add the `paginate` scope like so:

    class User < ActiveRecord::Base
      include Yap
      belongs_to :team
    end

##### Defaults (optional)

To setup default parameters call `Yap.configure`. You can access the defaults as block parameter. Call this somewhere in
`config/initializers/`.

    Yap.configure do |defaults|
      defaults.page = 1
      defaults.per_page = 10
      defaults.sort = 'id'
      defaults.direction = 'ASC'
      defaults.disable_warnings = false
    end

The above settings will be applied if you do not set your own.

##### Custom Naming (optional)

ActiveRecords can implement the method map_name_to_column to define aliases for columns. This can be useful to hide
internal naming from users and to make sorting by associations possible (more on this below).

    COLUMN_MAP = {
        'team' => 'teams.name',
        'birthday' => 'date_of_birth'
    }
    def self.map_name_to_column(name)
      return COLUMN_MAP[name]
    end

## Usage

### Basics

Assuming you included `Yap` into `User`, you can now do something like this:

    User.paginate
    # => Page 1 with default order and size

    User.paginate(
        page:       1,
        per_page:   10,
        sort:       'id',
        direction:  'ASC'
    )
    # => Invocation with custom options.

    User.paginate(params).last_page
    # => Last page as a number for the previously paginated query
    User.paginate(params).range
    # => E.g. { from: 1, to: 10, total: 100 }
    User.paginate(params).total
    # => total number of results for this filters

    User.paginate(params).without_pagination do |rel|
      # access rel without limit and offset; filters still apply
      rel.count
    end
    # => total number of results

    User.paginate(
      sort: {
        'gender'        => 'desc',
        'date_of_birth' => 'asc'
      }
    )
    # => Sort by gender and date_of_birth (method 1)

    User.paginate(sort: 'gender,date_of_birth', direction: 'desc,asc')
    # => Sort by gender and date_of_birth (method 2)

    User.filter('gender' => 'f')
    # => All female users

    User.filter(
        'team_id' => '1,2',
        'gender' => 'm'
    )
    # => All males of teams 1 and 2

    User.filter(
        # Note that '0...3' means [0,1,2] while '0..3' means [0,1,2,3]
        'date_of_birth' => '1990-01-01...1991-01-01'
    )
    # => All users born in 1990

    User.filter('team_id' => '!null')
    # => All users with any team

    User.paginate(
        page:   1,
        filter: { 'team' => 'null' }
    )
    # => Combining filter and pagination

    User.paginate(params)
    # => Passing parameters in controller (http://localhost/users?filter[gender]=f)

Yap will convert strings to symbols or numbers and vice versa where necessary. This make the last one a really powerful
method of offering the pagination API directly to the user.

### Chaining

The `paginate` scope can be chained with other `ActiveRecord` methods like `joins`, `where` etc..

### Advanced

The "team" alias defined in the column map above allows us to sort the results by the name of the team a user belongs
to. "teams.name" describes the "teams" table and the "name" column in our database. We need to join the team
association to make this work. Example:

    User.joins(:team).paginate(sort: 'team')

## Error Handling

If an option cannot be parsed it will raise `Yap::PaginationError` or `Yap::FilterError`, which are both
`Yap::YapError`s. I suggest to use `rescue_from` in the controller to handle such a case.

    rescue_from Yap::YapError, with: :handle_yap_error

    def handle_yap_error
      # generate user friendly error here, set flash[:error] or whatever you like.
    end

## Full Example

    require 'yap'

    class User < ActiveRecord::Base
      include Yap
      belongs_to :team

      COLUMN_MAP = {
          'team' => 'teams.name',
          'birthday' => 'date_of_birth'
      }
      def self.map_name_to_column(name)
        return COLUMN_MAP[name]
      end
    end

    class UsersController < ApplicationController
      rescue_from Yap::YapError, with: :handle_yap_error

      def handle_yap_error
        # generate user friendly error here, set flash[:error] or whatever you like.
      end

      def index
        respond_with User.joins(:team).paginate(params)
      end
    end

## Changelog

### 1.4

* added support for strings and dates with comparison parameters

### 1.3

* added comparison operators <, >, <=, >= to filters
  * usage: ?filter[id]=>=100
    * will give you any element with and id equal to or greater 100
  * you can even combine multiple filters: ?filter[id]=>=100,<200
    * although the same result can be achieved through ?filter[id]=100...200
* ~~_currently, there is no support for strings and dates. This will be implemented in the future._~~ (see version 1.4)

### 1.2

* added sorting by multiple elements
  * method 1: ?sort[team]=desc&sort[date_of_birth]=asc
  * method 2: ?sort=team,date_of_birth&direction=desc,asc
    * missing directions will fall back to default

### 1.1

* changed default behavior for `range` to not include `total`; saves time when using `range`
  * call `range(true)` to include total value

### 1.0

* changed `last_page` to base on the actual query not only the parameters
    * this now produces correct results if there are custom `where` conditions
* added `range` method which can be used like `last_page`
    * provides a hash containing the limits of the latest queried page
* added `total` method to get the total number of results
* added `without_pagination` which takes a block an serves an `Activerecord::Relation` which is not paginated
