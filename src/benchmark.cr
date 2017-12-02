require "benchmark"
require "radix"
require "./amber_router"

class Benchmarker
  getter route_library
  getter route_checks
  getter amber_router
  getter radix_router

  def initialize
    @route_library = {
      "/get/"                   => :root,
      "/get/users/:id"          => :users,
      "/get/users/:id/books"    => :users_books,
      "/get/books/:id"          => :books,
      "/get/books/:id/chapters" => :book_chapters,
      "/get/books/:id/authors"  => :book_authors,
      "/get/books/:id/pictures" => :book_pictures,
      "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z" => :alphabet,
      "/get/var/:b/:c/:d/:e/:f/:g/:h/:i/:j/:k/:l/:m/:n/:o/:p/:q/:r/:s/:t/:u/:v/:w/:x/:y/:z" => :variable_alphabet,
      "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/:id"   => :foobar_bat,
      "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/:id"   => :foobar_bom
    }

    @amber_router = Amber::Router::RouteSet(Symbol).new
    @radix_router = Radix::Tree(Symbol).new

    route_library.each do |k, v|
      radix_router.add(k, v)
      amber_router.add(k, v)
    end
  end

  def run_check(router, check, expected_result)
    result = router.find(check)

    if expected_result.nil?
      raise "returned a result when it shouldn't've" unless result.found? == false
      return
    end

    actual_result = result.payload

    if actual_result != expected_result
      raise "#{actual_result} did not match #{expected_result}"
    end
  end

  def compare(name : String, route : String, result : Symbol?)
    puts route

     Benchmark.ips do |x|
       x.report("router: #{name}") { run_check(amber_router, route, result) }
       x.report("radix: #{name}") { run_check(radix_router, route, result) }
     end

    puts
    puts
  end

  def go
    compare "root", "/get/", :root
    compare "deep", "/get/books/23/chapters", :book_chapters
    compare "wrong", "/get/books/23/pages", nil
    compare "many segments", "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z", :alphabet
    compare "many variables", "/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6", :variable_alphabet
    compare "long_segments", "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3", :foobar_bat
  end
end

Benchmarker.new.go
