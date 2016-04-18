require "forwardable"

module Goldmine
  class RollupResult
    extend Forwardable
    include Enumerable
    def_delegators :@pivot_result, :[], :[]=, :each, :to_h

    def initialize(pivot_result={})
      @pivot_result = pivot_result
    end

    def to_rows
      pivot_result.each_with_object([]) do |pair, memo|
        memo << pair.first + pair.last
      end
    end

    def to_hash_rows
      pivot_result.each_with_object([]) do |pair, memo|
        memo << (pair.first + pair.last).to_h
      end
    end

    def to_tabular
      rows = to_rows
      values = rows.map { |r| r.map(&:last) }
      values.unshift (rows.first || []).map(&:first)
      values
    end

    private

    attr_reader :pivot_result

  end
end
