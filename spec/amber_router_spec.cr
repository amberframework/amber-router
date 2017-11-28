require "./spec_helper"

def build
  Amber::Router::RouteSet(Symbol).new.tap do |router|
    router.add "/get", :root
  end
end

def build(&block)
  router = build
  with router yield
  router
end

describe Amber::Router::RouteSet do
  it "resolves the root route" do
    build.find("/get").payload.should eq :root
  end

  it "resolves deep urls" do
    router = build do
      add "/get/books/23/chapters", :book_chapters
    end

    result = router.find "/get/books/23/chapters"
    result.payload.should eq :book_chapters
  end

  it "returns a nil payload for not found urls" do
    router = build

    result = router.find "/get/books/23/pages"
    result.found?.should eq false
    result.payload.should eq nil
  end

  it "routes many segments" do
    router = build do
      add "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z", :alphabet
    end

    result = router.find "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
    result.payload.should eq :alphabet
  end

  it "routes many variables" do
    router = build do
      add "/get/var/:b/:c/:d/:e/:f/:g/:h/:i/:j/:k/:l/:m/:n/:o/:p/:q/:r/:s/:t/:u/:v/:w/:x/:y/:z", :variable_alphabet
    end

    result = router.find "/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6"
    result.payload.should eq :variable_alphabet
  end

  it "correctly selects routes" do
    router = build do
      add "/get/users/:id",          :users
      add "/get/users/:id/books",    :users_books
      add "/get/books/:id",          :books
      add "/get/books/:id/chapters", :book_chapters
      add "/get/books/:id/authors",  :book_authors
      add "/get/books/:id/pictures", :book_pictures
    end

    router.find("/get/")                   .payload.should eq :root
    router.find("/get/users/3")            .payload.should eq :users
    router.find("/get/users/3/books")    .payload.should eq :users_books
    router.find("/get/books/3")          .payload.should eq :books
    router.find("/get/books/3/chapters") .payload.should eq :book_chapters
    router.find("/get/books/3/authors")  .payload.should eq :book_authors
    router.find("/get/books/3/pictures") .payload.should eq :book_pictures
    router.find("/get/books/3/pages")    .payload.should eq nil
  end

  it "resolves glob urls" do
    router = build do
      add "/get/products/*", :products_slug
    end

    router.find("/get/products/fancy_hairdoo").payload.should eq :products_slug
  end

  it "resolves glob urls with a suffix" do
    router = build do
      add "/get/products/*/with_name", :products_slug_with_name
    end

    router.find("/get/products/fancy_hairdoo/with_name").payload.should eq :products_slug_with_name
  end

  it "handles partially shared keys" do
    # from https://github.com/luislavena/radix/blob/master/spec/radix/tree_spec.cr#L536
    # tree = Tree(Symbol).new
    # tree.add "/orders/:id", :specific_order
    # tree.add "/orders/closed", :closed_orders

    # result = tree.find("/orders/10")
    # result.found?.should be_true
    # result.key.should eq("/orders/:id")
    # result.params.has_key?("id").should be_true
    # result.params["id"].should eq("10")
  end

end
