# Amber/Router [![Build Status](https://travis-ci.org/amberframework/amber-router.svg?branch=master)](https://travis-ci.org/amberframework/amber-router) [![Latest Release](https://img.shields.io/github/release/amberframework/amber-router.svg)](https://github.com/amberframework/amber-router/releases)

A tree based url router with a similar API interface to [radix](https://github.com/luislavena/radix).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  amber_router:
    github: amberframework/amber-router
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
amber_router: root   4.90M (203.95ns) (± 2.77%)  385B/op   1.16× slower
       radix: root   5.70M (175.37ns) (± 3.84%)  224B/op        fastest

/get/books/23/chapters
amber_router: deep   1.75M (571.75ns) (± 4.36%)  915B/op        fastest
       radix: deep   1.50M (668.47ns) (± 4.31%)  544B/op   1.17× slower

/get/books/23/pages
amber_router: wrong   2.64M (378.30ns) (± 5.51%)  593B/op        fastest
       radix: wrong   1.74M (573.41ns) (± 2.84%)  464B/op   1.52× slower

/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
amber_router: many segments 501.49k (  1.99µs) (± 2.83%)  4.03kB/op   4.01× slower
       radix: many segments   2.01M (496.78ns) (± 3.32%)    353B/op        fastest

/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
amber_router: many variables 314.33k (  3.18µs) (± 3.33%)  6.05kB/op   1.41× slower
       radix: many variables 442.56k (  2.26µs) (± 2.14%)  2.73kB/op        fastest

/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
amber_router: long segments   1.95M (512.99ns) (± 2.24%)  786B/op        fastest
       radix: long segments   1.12M (891.73ns) (± 2.41%)  576B/op   1.74× slower

/post/products/23/reviews/
amber_router: catchall route   2.52M (396.60ns) (± 4.75%)  704B/op   1.49× slower
       radix: catchall route   3.75M (266.85ns) (± 1.80%)  401B/op        fastest

/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match   1.33M (749.41ns) (± 1.85%)  1.25kB/op  fastest

Route constraints
   route with a valid constraint   1.88M (531.64ns) (± 1.56%)  786B/op   1.43× slower
route with an invalid constraint   2.68M (372.50ns) (± 2.22%)  497B/op        fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `examples/benchmark.cr` as an update to this readme.
