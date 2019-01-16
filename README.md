# Amber/Router [![Build Status](https://travis-ci.org/amberframework/amber-router.svg?branch=master)](https://travis-ci.org/amberframework/amber-router) [![Latest Release](https://img.shields.io/github/release/amberframework/amber-router.svg)](https://github.com/amberframework/amber-router/releases)

A tree based url router with a similar API interface to [radix](https://github.com/luislavena/radix).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  amber_router:
    github: amberframework/amber_router
```

## Usage

```crystal
require "amber_router"

route_set = Amber::Router::RouteSet(Symbol).new
route_set.add "/get/", :root

# A `:` at the start of a segment indicates a named parameter
route_set.add "/get/users/:id", :users
route_set.add "/get/users/:id/books", :users_books

# A `*` at the start of a segment indicates a glob parameter
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

route_set.find("/get/posts/1").found? # => true
route_set.find("/get/posts/foo").found? # => false

route_set.find("/get/test/foo_7").found? # => true
route_set.find("/get/test/foo_").found? # => false

# Finding routes from a payload:
route_set.find("/get/users/3").payload # => :users
route_set.find("/get/users/3/books").payload # => :users_books
route_set.find("/get/books/3").payload # => :book

# `RoutedResult` returns payload and named parameters
result = route_set.find("/get/posts/my_trip_to_kansas/comments")
result.found? # => true
result.params # => {"post_name" => "my_trip_to_kansas"}
```

## Performance

`crystal run examples/benchmark.cr --release` produces a comparison of this router and [radix](https://github.com/luislavena/radix). As of now, this is the comparison:

```text
$ crystal run examples/benchmark.cr --release

/get/
amber_router: root   3.63M (275.23ns) (± 5.58%)  546 B/op   1.44× slower
       radix: root   5.25M (190.49ns) (± 4.07%)  320 B/op        fastest

/get/books/23/chapters
amber_router: deep   1.73M (578.29ns) (± 4.25%)  1040 B/op        fastest
       radix: deep   1.54M ( 647.9ns) (± 5.46%)   592 B/op   1.12× slower

/get/books/23/pages
amber_router: wrong   2.46M (406.07ns) (± 1.50%)  768 B/op        fastest
       radix: wrong   1.85M ( 541.1ns) (± 2.09%)  513 B/op   1.33× slower

/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
amber_router: many segments 475.73k (   2.1µs) (± 3.78%)  4498 B/op   4.31× slower
       radix: many segments   2.05M (488.09ns) (± 1.28%)   448 B/op        fastest

/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
amber_router: many variables 276.63k (  3.61µs) (± 4.65%)  6517 B/op   1.44× slower
       radix: many variables 397.75k (  2.51µs) (± 1.67%)  2853 B/op        fastest

/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
amber_router: long segments   1.83M (546.36ns) (± 2.03%)  912 B/op        fastest
       radix: long segments   1.19M ( 842.9ns) (± 1.46%)  624 B/op   1.54× slower

/post/products/23/reviews/
amber_router: catchall route    2.2M (455.48ns) (± 1.13%)  896 B/op   1.66× slower
       radix: catchall route   3.65M (274.33ns) (± 4.71%)  449 B/op        fastest

/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match   1.18M (845.37ns) (± 1.27%)  1489 B/op  fastest

Route constraints
   route with a valid constraint 1.84M (544.55ns) (± 1.11%)  912 B/op   1.31× slower
route with an invalid constraint 2.41M (414.72ns) (± 1.25%)  672 B/op        fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `examples/benchmark.cr` as an update to this readme.
