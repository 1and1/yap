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

    User.paginate                       # => Page 1 with default order and size
    User.paginate(
        page:       1,
        per_page:   10,
        sort:       'id',
        direction:  'ASC'
    )                                   # => Invocation with custom options.

    User.paginate(params).last_page     # => Last page as a number for the previous paginated query

    User.paginate(params).range         # => E.g. { from: 1, to: 10, total: 100 }

    User.filter('gender' => 'f')        # => All female users
    User.filter(
        'team_id' => '1,2',
        'gender' => 'm'
    )                                   # => All males of teams 1 and 2
    User.filter(
        'date_of_birth' => '1990-01-01..1991-01-01'
    )                                   # => All users born in 1990
    User.filter('team_id' => '!null')   # => All users with any team
    User.paginate(
        page:   1,
        filter: { 'team' => 'null' }
    )                                   # => Combining filter and pagination

    User.paginate(params)               # => Passing parameters in controller (http://localhost/users?filter[gender]=f)

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

## ToDos

* Maximum for per_page
* Make gathering total/range optional

## Changelog

### 1.0.0

* changed `last_page` to base on the actual query not only the parameters
    * this now produces correct results if there are custom `where` conditions
* added `range` attribute which can be used like `last_page`
    * provides a hash containing the limits of the latest queried page
* added `without_limit`
* added `total`
