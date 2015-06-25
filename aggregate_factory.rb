class AggregateFactory
  # will not work
  def self.create_aggregate(klass)
    "#{klass}::Aggregate".constantize.new
  end
end