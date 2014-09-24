require_relative './test_helper'

class VersionTest < Test::Unit::TestCase
  def test_must_have_const_VERSION
    assert(Verp.const_defined? :VERSION)
  end

  def test_must_have_method_version
    assert_respond_to(Verp, :version)
  end
end
