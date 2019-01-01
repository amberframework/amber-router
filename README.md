# Amber/Router

[![Build Status](https://travis-ci.org/amberframework/amber-router.svg?branch=master)](https://travis-ci.org/amberframework/amber-router) A tree based url router with a similar API interface to [radix](luislavena/radix).

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
router: root   3.75M (266.75ns) (± 2.15%)  545 B/op   1.36× slower
radix: root   5.09M (196.42ns) (± 2.62%)  321 B/op        fastest


/get/books/23/chapters
router: deep   1.68M (594.77ns) (± 2.02%)  1041 B/op        fastest
radix: deep   1.53M (654.95ns) (± 5.03%)   592 B/op   1.10× slower


/get/books/23/pages
router: wrong   2.36M (423.88ns) (± 2.74%)  768 B/op        fastest
radix: wrong   1.73M (578.03ns) (± 2.21%)  514 B/op   1.36× slower


/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 453.85k (   2.2µs) (± 5.73%)  4500 B/op   4.29× slower
radix: many segments   1.95M (513.66ns) (± 2.44%)   449 B/op        fastest


/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables 265.79k (  3.76µs) (± 1.70%)  6529 B/op   1.49× slower
radix: many variables 396.79k (  2.52µs) (± 1.93%)  2850 B/op        fastest


/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments   1.74M (573.13ns) (± 2.54%)  912 B/op        fastest
radix: long_segments   1.12M (895.61ns) (± 2.03%)  624 B/op   1.56× slower


/post/products/23/reviews/
router: catchall route   2.08M (480.64ns) (± 3.67%)  928 B/op   1.72× slower
radix: catchall route   3.58M (279.59ns) (± 3.24%)  448 B/op        fastest


/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match   1.12M (896.18ns) (± 2.20%)  1584 B/op  fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `src/benchmark.cr` as an update to this readme.
