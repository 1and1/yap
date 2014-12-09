yap
===

Yet another paginator for Ruby on Rails, which adds a paginate scope to your ActiveRecords.

Setup
-----

To setup default parameters call Yap configure. You can access the defaults as block parameter.

    Yap.configure do |defaults|
      defaults.page = 1
      defaults.per_page = 10
      defaults.sort = :id
      defaults.direction = :asc
    end
