#
# Usage:
#

class Command < Struct
  attr_accessor :version

  def expected_version
    original_version + 1
  end
end