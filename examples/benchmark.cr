require "benchmark"
require "colorize"
require "radix"
require "../src/amber_router"

class Benchmarker
  getter amber_router
  getter radix_router

  def initialize
    @amber_router = Amber::Router::RouteSet(Symbol).new
    @radix_router = Radix::Tree(Symbol).new

    @shared_routes = {
      "/get/"                                                                               => :root,
      "/get/users/:id"                                                                      => :users,
      "/get/users/:id/books"                                                                => :users_books,
      "/get/books/:id"                                                                      => :books,
      "/get/books/:id/chapters"                                                             => :book_chapters,
      "/get/books/:id/authors"                                                              => :book_authors,
      "/get/books/:id/pictures"                                                             => :book_pictures,
      "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"                            => :alphabet,
      "/get/var/:b/:c/:d/:e/:f/:g/:h/:i/:j/:k/:l/:m/:n/:o/:p/:q/:r/:s/:t/:u/:v/:w/:x/:y/:z" => :variable_alphabet,
      "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/:id"                           => :foobar_bat,
      "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/:id"                           => :foobar_bom,
      "/post/*"                                                                             => :catchall,
    }

    @shared_routes.each do |k, v|
      amber_router.add k, v
      radix_router.add k, v
    end

    @shared_test_paths = {
      {"root", "/get/", :root},
      {"deep", "/get/books/23/chapters", :book_chapters},
      {"wrong", "/get/books/23/pages", nil},
      {"many segments", "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z", :alphabet},
      {"many variables", "/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6", :variable_alphabet},
      {"long segments", "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3", :foobar_bat},
      {"catchall route", "/post/products/23/reviews/", :catchall},
    }
  end

  private def run_check(router, check, expected_result)
    result = router.find(check)

    unless expected_result
      raise "Returned a result when it shouldn't have" if result.found?
      return
    end

    actual_result = result.payload

    unless actual_result == expected_result
      raise "#{router.class} #{actual_result.inspect} did not match #{expected_result}"
    end
  end

  private def compare(name : String, route : String, result : Symbol?)
    puts route.colorize(:white).bold

    Benchmark.ips do |x|
      x.report("amber_router: #{name.colorize(:light_green)}") do
        run_check(amber_router, route, result)
      end
      x.report("radix: #{name.colorize(:light_green)}") do
        run_check(radix_router, route, result)
      end
    end

    puts
  end

  def compare_to_radix
    @shared_test_paths.each do |(desc, path, payload)|
      compare desc, path, payload
    end
  end

  def benchmark_self
    amber_router.add "/put/products/*slug/dp/:id", :amazon_style_url

    amazon_style_url = "/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ"
    puts amazon_style_url.colorize(:white).bold
    Benchmark.ips do |x|
      x.report("globs with suffix match") do
        run_check(amber_router, amazon_style_url, :amazon_style_url)
      end
    end

    puts

    # Add a route with a requirement
    amber_router.add "/get/test/:id", :requirement_path, {:id => /foo_\d/}

    puts "Route constraints".colorize(:yellow).bold
    Benchmark.ips do |x|
      x.report("route with a valid constraint") do
        run_check(amber_router, "/get/test/foo_99", :requirement_path)
      end
      x.report("route with an invalid constraint") do
        run_check(amber_router, "/get/test/foo_bar", nil)
      end
    end
  end
end

benchmarker = Benchmarker.new
benchmarker.compare_to_radix
benchmarker.benchmark_self
