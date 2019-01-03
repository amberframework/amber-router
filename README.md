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

# Supports `Regex` based argument constraints
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
router: root   3.52M ( 284.1ns) (± 2.61%)  546 B/op   1.46× slower
 radix: root   5.14M (194.63ns) (± 2.14%)  320 B/op        fastest

/get/books/23/chapters
router: deep   1.63M (613.93ns) (± 5.10%)  1040 B/op        fastest
 radix: deep   1.54M (648.07ns) (± 3.47%)   592 B/op   1.06× slower

/get/books/23/pages
router: wrong   2.19M (457.17ns) (± 5.27%)  768 B/op        fastest
 radix: wrong   1.68M ( 595.0ns) (± 6.28%)  513 B/op   1.30× slower

/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 425.24k (  2.35µs) (± 7.27%)  4498 B/op   4.45× slower
 radix: many segments   1.89M (529.03ns) (± 4.81%)   448 B/op        fastest

/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables 259.29k (  3.86µs) (± 5.15%)  6518 B/op   1.47× slower
 radix: many variables 381.89k (  2.62µs) (± 4.13%)  2851 B/op        fastest

/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments   1.65M (607.19ns) (± 2.42%)  912 B/op        fastest
 radix: long_segments   1.08M (923.73ns) (± 5.42%)  624 B/op   1.52× slower

/post/products/23/reviews/
router: catchall route   2.05M (488.77ns) (± 2.60%)  896 B/op   1.69× slower
 radix: catchall route   3.46M (289.16ns) (± 4.36%)  448 B/op        fastest

/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match   1.11M ( 901.3ns) (± 3.29%)  1489 B/op  fastest

Route Requirements
route with requirement   1.73M (578.97ns) (± 2.81%)  912 B/op   1.31× slower
route with requirement   2.26M (442.06ns) (± 1.81%)  672 B/op        fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `src/benchmark.cr` as an update to this readme.
