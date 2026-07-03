require "test_helper"
require "net/http"

class BookLookupTest < ActiveSupport::TestCase
  VALID_ISBN   = "9780134757599"
  UNKNOWN_ISBN = "0000000000"

  setup do
    Rails.cache.clear
  end

  test "lookup_isbn returns hash with title, author, cover_url" do
    stub_get_response(success_response(VALID_ISBN)) do
      result = Book.lookup_isbn(VALID_ISBN)

      assert_equal "Refactoring", result[:title]
      assert_equal "Martin Fowler", result[:author]
      assert_includes result[:cover_url], VALID_ISBN
    end
  end

  test "returns nil on API failure" do
    stub_get_response(failure_response) do
      assert_nil Book.lookup_isbn(UNKNOWN_ISBN)
    end
  end

  test "caches results for subsequent calls" do
    call_count = 0
    counting = ->(_uri) { call_count += 1; success_response(VALID_ISBN) }

    with_memory_cache do
      stub_get_response(counting) do
        Book.lookup_isbn(VALID_ISBN)
        Book.lookup_isbn(VALID_ISBN)
      end
    end

    assert_equal 1, call_count
  end

  private
    def stub_get_response(response)
      original = Net::HTTP.method(:get_response)
      Net::HTTP.define_singleton_method(:get_response) do |uri|
        response.respond_to?(:call) ? response.call(uri) : response
      end
      yield
    ensure
      Net::HTTP.define_singleton_method(:get_response, original)
    end

    def success_response(isbn)
      body = {
        "ISBN:#{isbn}" => {
          "title"   => "Refactoring",
          "authors" => [ { "name" => "Martin Fowler" } ]
        }
      }.to_json

      Net::HTTPSuccess.new("1.1", "200", "OK").tap do |resp|
        resp.instance_variable_set(:@body, body)
        resp.instance_variable_set(:@read, true)
      end
    end

    def failure_response
      Net::HTTPNotFound.new("1.1", "404", "Not Found").tap do |resp|
        resp.instance_variable_set(:@body, "{}")
        resp.instance_variable_set(:@read, true)
      end
    end

    def with_memory_cache
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      yield
    ensure
      Rails.cache = original
    end
end
