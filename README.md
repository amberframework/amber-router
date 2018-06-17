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

```
> crystal run src/benchmark.cr --release
/get/
router: root   1.68M (596.67ns) (± 5.64%)  1.37× slower
 radix: root    2.3M (435.57ns) (± 5.08%)       fastest


/get/books/23/chapters
router: deep 986.19k (  1.01µs) (± 4.84%)       fastest
 radix: deep 907.61k (   1.1µs) (± 7.06%)  1.09× slower


/get/books/23/pages
router: wrong   1.42M (702.46ns) (± 3.84%)       fastest
 radix: wrong   1.01M (991.22ns) (± 1.30%)  1.41× slower


/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 225.66k (  4.43µs) (± 3.87%)  5.38× slower
 radix: many segments   1.21M ( 824.2ns) (± 1.36%)       fastest


/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables 143.56k (  6.97µs) (± 4.55%)  1.50× slower
 radix: many variables 215.03k (  4.65µs) (± 1.70%)       fastest


/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments   1.13M (885.26ns) (± 2.95%)       fastest
 radix: long_segments 737.03k (  1.36µs) (± 3.71%)  1.53× slower


/post/products/23/reviews/
router: catchall route   1.21M (828.65ns) (± 4.67%)  1.52× slower
 radix: catchall route   1.84M (544.43ns) (± 3.36%)       fastest


/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match 667.91k (   1.5µs) (± 3.89%) fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `src/benchmark.cr` as an update to this readme.
