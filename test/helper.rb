require "rubygems"
require "minitest/spec"
require "rack/test"
require "webmock/test_unit"

MiniTest::Unit.autorun

require "chronologic"

class MiniTest::Unit::TestCase

  def chronologic_schema
    schema = Chronologic::Schema.new
    schema.connection = Cassandra.new("Chronologic")
    schema.connection.clear_keyspace!
    schema
  end

end
