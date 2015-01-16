# yap v0.1.0

Yet another paginator for Ruby on Rails, which adds a `paginate` scope to your ActiveRecords.

## Setup

Include `Yap` into your models to add the `paginate` scope like so:

    class User < ActiveRecord::Base
      include Yap
      belongs_to :team
    end

###### Defaults (optional)

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

###### Custom Naming (optional)

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

    User.paginate           # => Page 1 with default order and size.
    User.paginate(params)   # => Use this in controller to pass query parameters.
    User.paginate(
        page:       1,
        per_page:   10,
        sort:       'id',
        direction:  'ASC'
    )                       # => Invocation with custom options.

    User.last_page          # => Last page as a number for defaults
    User.last_page(params)  # => Last page for given params. Works the same way as paginate.

Yap will convert strings to symbols or numbers and vice versa where necessary.

### Advanced

The "team" alias defined in the column map above allows us to sort the results by the name of the team a user belongs
to. "teams.name" describes the "teams" table and the "name" column in our database. We need to join the team
association to make this work. Example:

    User.joins(:team).paginate(sort: 'team')

## Error Handling

If an option cannot be parsed it will
raise `Yap::PaginationError`. I suggest to use `rescue_from` in the controller to handle such a case.

    rescue_from Yap::PaginationError, with: :handle_pagination_error

    def handle_pagination_error
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
      rescue_from Yap::PaginationError, with: :handle_pagination_error

      def handle_pagination_error
        # generate user friendly error here, set flash[:error] or whatever you like.
      end

      def index
        respond_with User.joins(:team).paginate(params)
      end
    end

## ToDos

* Document filtering
