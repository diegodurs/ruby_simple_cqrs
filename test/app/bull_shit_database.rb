class BullShitDatabase
  def self.list
    @list ||= Table.new(:list)
  end

  class Table < Array
    def initialize(name)
      @name = name
    end

    alias_method :add, :<<
    alias_method :remove_all, :delete_if
  end
end