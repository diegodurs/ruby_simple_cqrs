#
# Usage:
#   ```ruby
#   MyEvent = Event.new(:id)
#   e = MyEvent.new('myId')
#   e.version = 1
#   e.to_h
#   e.serialize
#   ```
#

require 'json'
class Event < Struct
  attr_accessor :version, :timestamp

  # def serialize(formatter = ->(hash) { hash.to_json} )
  #   hash = to_h
  #   hash.each do |k,v|
  #     raise "unserializable value #{k}:#{v}" unless [String, Fixnum].include?(v.class)
  #   end
  #   formatter.call(hash)
  # end

  # def to_h
  #   hash = {version: version, timestamp: timestamp}
  #   members.each_with_index do |key, position|
  #     hash[key] = values[position]
  #   end
  #   hash
  # end
end