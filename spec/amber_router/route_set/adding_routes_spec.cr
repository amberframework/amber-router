require "../../spec_helper"

describe "adding routes" do
  it "allows adding duplicate paths" do
    # expect_not_raises
    router = build do
      add "get", :get
      add "get", :get
      add "post", :get
      add "post", :get
    end
  end
end
