# yap

Yet another paginator for Ruby on Rails, which adds a `paginate` scope to your ActiveRecords.

## Setup

Include `Yap` into your models to add the `paginate` scope like so:

    class User < ActiveRecord::Base
      include Yap
    end

###### Optional

To setup default parameters call `Yap.configure`. You can access the defaults as block parameter. Call this somewhere in
`config/initializers/`.

    Yap.configure do |defaults|
      defaults.page = 1
      defaults.per_page = 10
      defaults.sort = :id
      defaults.direction = :asc
    end

The options from the example below are the defaults which are applied if you do not set your own.

## Usage

Assuming you included `Yap` into `User`, you can now do something like this:

    User.paginate         # => Page 1 with default order and size.
    User.paginate(params) # => Use this in controller to pass query parameters.
    User.paginate(
        page:       1,
        per_page:   10,
        sort:       :id,
        direction:  :asc
    )                     # => Invocation with custom options.

Yap will convert strings to symbols or numbers and vice versa where necessary. If an option cannot be parsed it will
raise `Yap::PaginationError`. I suggest to use `rescue_from` in the controller to handle such a case.

    rescue_from Yap::PaginationError, with: :handle_pagination_error

    def handle_pagination_error
      # generate user friendly error here, set flash[:error] or whatever you like.
    end
