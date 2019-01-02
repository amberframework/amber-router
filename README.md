# Amber/Router

[![Build Status](https://travis-ci.org/amberframework/amber-router.svg?branch=master)](https://travis-ci.org/amberframework/amber-router) A tree based url router with a similar API interface to [radix](https://github.com/luislavena/radix).

## Usage

```crystal
require "./amber_router"

route_set = Amber::Router::RouteSet(Symbol).new
route_set.add "/get/", :root

# A : at the start of a segment indicates a named parameter
route_set.add "/get/users/:id", :users
route_set.add "/get/users/:id/books", :users_books

# A * at the start of a segment indicates a glob parameter
route_set.add "/get/users/comments/*date_range"

# Supports storing multiple named arguments at the same position
route_set.add "/get/users/:user_id/books/:23", :user_book

# Predictably matches by insertion order so route overloads work as expected
route_set.add "/get/books/mine", :my_books
route_set.add "/get/books/:id", :book
route_set.add "/get/books/:id/chapters", :book_chapters

# Supports globs with a suffix
route_set.add "/get/posts/*post_name/comments", :wordpress_style

# Supports match-all globs.
route_set.add "/get/*", :catch_all

# Supports `Regex` based argument requirements
route_set.add "/get/posts/:page", :user_path, {"page" => /\d+/}
route_set.add "/get/test/:id", :user_path, {"id" => /foo_\d/}

router.find("/get/posts/1").found? # => true
router.find("/get/posts/foo").found? # => false

router.find("/get/test/foo_7").found? # => true
router.find("/get/test/foo_").found? # => false


# Finding routes from a payload:
route_set.find("/get/users/3").payload # => :users
route_set.find("/get/users/3/books").payload # => :users_books
route_set.find("/get/books/3").payload #=> :book

# RoutingResults return payload and named parameters
result = route_set.find("/get/posts/my_trip_to_kansas/comments")
result.terminal_segment.full_path
result.found? #=> true
result.params #=> { "post_name" => "my_trip_to_kansas" }
```

## Performance

`crystal run src/benchmark.cr --release` produces a comparison of this router and [radix](https://github.com/luislavena/radix). As of now, this is the comparison:

```Text
> crystal run src/benchmark.cr --release
/get/
router: root   3.76M (266.26ns) (± 4.05%)  546 B/op   1.48× slower
 radix: root   5.56M (179.89ns) (± 1.38%)  320 B/op        fastest

/get/books/23/chapters
router: deep   1.76M (566.64ns) (± 1.49%)  1040 B/op        fastest
 radix: deep   1.69M (592.92ns) (± 1.63%)   592 B/op   1.05× slower

/get/books/23/pages
router: wrong   2.44M (410.43ns) (± 1.41%)  768 B/op        fastest
 radix: wrong   1.79M ( 560.0ns) (± 6.56%)  514 B/op   1.36× slower

/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 485.02k (  2.06µs) (± 1.67%)  4496 B/op   4.24× slower
 radix: many segments   2.06M (485.98ns) (± 9.72%)   449 B/op        fastest

/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables 277.63k (   3.6µs) (± 1.88%)  6528 B/op   1.52× slower
 radix: many variables  421.4k (  2.37µs) (± 2.92%)  2849 B/op        fastest

/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments    1.8M (555.57ns) (± 1.34%)  912 B/op        fastest
 radix: long_segments   1.23M (812.44ns) (± 1.97%)  624 B/op   1.46× slower

/post/products/23/reviews/
router: catchall route    2.2M (455.36ns) (± 0.91%)  896 B/op   1.73× slower
 radix: catchall route   3.81M (262.62ns) (± 1.60%)  449 B/op        fastest

/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match   1.18M (844.57ns) (± 1.41%)  1489 B/op  fastest

Route Requirements
route with requirement   1.83M ( 545.2ns) (± 1.11%)  912 B/op  fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `src/benchmark.cr` as an update to this readme.
