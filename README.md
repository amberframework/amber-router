# Amber/Router

An experimental url router.

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
/get/
router: root   1.89M (528.64ns) (± 6.74%)  1.39× slower
 radix: root   2.63M (380.58ns) (± 7.76%)       fastest


/get/books/23/chapters
router: deep 905.13k (   1.1µs) (± 8.08%)       fastest
 radix: deep 864.83k (  1.16µs) (± 4.51%)  1.05× slower


/get/books/23/pages
router: wrong   1.38M (723.32ns) (± 4.60%)       fastest
 radix: wrong   1.08M (928.85ns) (± 3.14%)  1.28× slower


/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 225.91k (  4.43µs) (± 6.60%)  5.59× slower
 radix: many segments   1.26M (792.01ns) (± 5.87%)       fastest


/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables  144.4k (  6.93µs) (± 4.91%)  1.74× slower
 radix: many variables 251.57k (  3.98µs) (± 5.11%)       fastest


/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments   1.14M (879.49ns) (± 6.36%)       fastest
 radix: long_segments 760.79k (  1.31µs) (± 4.41%)  1.49× slower


/post/products/23/reviews/
router: catchall route   1.22M ( 820.1ns) (± 4.77%)  1.61× slower
 radix: catchall route   1.96M (510.91ns) (± 4.64%)       fastest


/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ
globs with suffix match 674.26k (  1.48µs) (± 7.43%) fastest
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request. Please include the output of `src/benchmark.cr` as an update to this readme.
