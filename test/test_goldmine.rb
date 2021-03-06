require "pry-test"
require "coveralls"
Coveralls.wear!
SimpleCov.command_name "pry-test"
require File.expand_path("../../lib/goldmine", __FILE__)

class TestGoldmine < PryTest::Test

  # pivots .....................................................................

  test "simple pivot" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .to_h

    expected = {
      [["< 5", true]]  => [1, 2, 3, 4],
      [["< 5", false]] => [5, 6, 7, 8, 9]
    }

    assert actual == expected
  end

  test "chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .pivot("even") { |i| i % 2 == 0 }
      .to_h

    expected = {
      [["< 5", true],  ["even", false]] => [1, 3],
      [["< 5", true],  ["even", true]]  => [2, 4],
      [["< 5", false], ["even", false]] => [5, 7, 9],
      [["< 5", false], ["even", true]]  => [6, 8]
    }

    assert actual == expected
  end

  test "deep chained pivots" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 3") { |i| i < 3 }
      .pivot("< 6") { |i| i < 6 }
      .pivot("< 9") { |i| i < 9 }
      .pivot("even") { |i| i % 2 == 0 }
      .pivot("odd") { |i| i % 3 == 0 || i == 1 }
      .to_h

    expected = {
      [["< 3", true],  ["< 6", true],  ["< 9", true],  ["even", false], ["odd", true]]  => [1],
      [["< 3", true],  ["< 6", true],  ["< 9", true],  ["even", true],  ["odd", false]] => [2],
      [["< 3", false], ["< 6", true],  ["< 9", true],  ["even", false], ["odd", true]]  => [3],
      [["< 3", false], ["< 6", true],  ["< 9", true],  ["even", true],  ["odd", false]] => [4],
      [["< 3", false], ["< 6", true],  ["< 9", true],  ["even", false], ["odd", false]] => [5],
      [["< 3", false], ["< 6", false], ["< 9", true],  ["even", true],  ["odd", true]]  => [6],
      [["< 3", false], ["< 6", false], ["< 9", true],  ["even", false], ["odd", false]] => [7],
      [["< 3", false], ["< 6", false], ["< 9", true],  ["even", true],  ["odd", false]] => [8],
      [["< 3", false], ["< 6", false], ["< 9", false], ["even", false], ["odd", true]]  => [9]
    }

    assert actual == expected
  end

  test "pivot of list values" do
    list = [
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    actual = Goldmine(list)
      .pivot("list value") { |record| record[:list] }
      .to_h

    expected = {
      ["list value", 1] => [{:name=>"one", :list=>[1]}, {:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 2] => [{:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 3] => [{:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 4] => [{:name=>"four", :list=>[1, 2, 3, 4]}]
    }

    assert actual == expected
  end

  test "pivot of list values with empty list" do
    list = [
      { :name => "empty", :list => [] },
      { :name => "one",   :list => [1] },
      { :name => "two",   :list => [1, 2] },
      { :name => "three", :list => [1, 2, 3] },
      { :name => "four",  :list => [1, 2, 3, 4] },
    ]
    actual = Goldmine(list)
      .pivot("list value") { |record| record[:list] }
      .to_h

    expected = {
      [["list value", nil]] => [{:name=>"empty", :list=>[]}],
      ["list value", 1]     => [{:name=>"one", :list=>[1]}, {:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 2]     => [{:name=>"two", :list=>[1, 2]}, {:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 3]     => [{:name=>"three", :list=>[1, 2, 3]}, {:name=>"four", :list=>[1, 2, 3, 4]}],
      ["list value", 4]     => [{:name=>"four", :list=>[1, 2, 3, 4]}]
    }

    assert actual == expected
  end

  # rollups ...................................................................

  test "simple pivot rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count) { |items| items.size }
      .to_h

    expected = {
      [["< 5", true]]  => [[:count, 4]],
      [["< 5", false]] => [[:count, 5]]
    }

    assert actual == expected
  end

  test "chained pivots rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .pivot("even") { |i| i % 2 == 0 }
      .rollup(:count) { |row| row.size }
      .to_h

    expected = {
      [["< 5", true],  ["even", false]] => [[:count, 2]],
      [["< 5", true],  ["even", true]]  => [[:count, 2]],
      [["< 5", false], ["even", false]] => [[:count, 3]],
      [["< 5", false], ["even", true]]  => [[:count, 2]]
    }

    assert actual == expected
  end

  test "pivot with chained rollup" do
    list = [1,2,3,4,5,6,7,8,9]
    list = Goldmine(list)
    actual = list
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count) { |items| items.size }
      .rollup(:div_by_3) { |items| items.keep_if { |i| i % 3 == 0 }.size }
      .to_h

    expected = {
      [["< 5", true]]  => [[:count, 4], [:div_by_3, 1]],
      [["< 5", false]] => [[:count, 5], [:div_by_3, 2]]
    }

    assert actual == expected
  end

  # to_rows ...................................................................

  test "simple pivot rollup to_rows" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count) { |items| items.size }
      .to_rows

    expected = [
      [["< 5", true],  [:count, 4]],
      [["< 5", false], [:count, 5]]
    ]

    assert actual == expected
  end

  test "chained pivots rollup to_rows" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .pivot("even") { |i| i % 2 == 0 }
      .rollup(:count) { |row| row.size }
      .to_rows

    expected = [
      [["< 5", true],  ["even", false], [:count, 2]],
      [["< 5", true],  ["even", true],  [:count, 2]],
      [["< 5", false], ["even", false], [:count, 3]],
      [["< 5", false], ["even", true],  [:count, 2]]
    ]

    assert actual == expected
  end

  test "simple pivot rollup to_hash_rows" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count) { |items| items.size }
      .to_hash_rows

    expected = [
      {"< 5" => true,  :count => 4},
      {"< 5" => false, :count => 5}
    ]

    assert actual == expected
  end

  # to_tabular ................................................................

  test "simple pivot rollup to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count, &:size)
      .to_tabular

    expected = [
      ["< 5", :count],
      [true, 4],
      [false, 5]
    ]

    assert actual == expected
  end

  test "chained pivots rollup to_tabular" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .pivot(:even) { |i| i % 2 == 0 }
      .rollup(:count, &:size)
      .to_tabular

    expected = [
      ["< 5", :even, :count],
      [true, false, 2],
      [true, true, 2],
      [false, false, 3],
      [false, true, 2]
    ]

    assert actual == expected
  end

  # to_csv_table ..............................................................

  test "simple pivot rollup to_csv" do
    list = [1,2,3,4,5,6,7,8,9]
    actual = Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count, &:size)
      .to_csv

    assert actual == "< 5,count\ntrue,4\nfalse,5\n"
  end

  # pivot_result cache ..........................................................

  test "pivot_result cache is available to rollups when setting on Goldmine" do
    list = [1,2,3,4,5,6,7,8,9]
    cached_counts = []
    Goldmine(list, cache: true)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count, &:size)
      .rollup(:cached_count) { |_| cached_counts << cache[:count] }
      .result

    assert cached_counts.size == 2
    assert cached_counts.first == 4
    assert cached_counts.last == 5
  end

  test "pivot_result cache is available to rollups when setting on result" do
    list = [1,2,3,4,5,6,7,8,9]
    cached_counts = []
    Goldmine(list)
      .pivot("< 5") { |i| i < 5 }
      .rollup(:count, &:size)
      .rollup(:cached_count) { |_| cached_counts << cache[:count] }
      .result(cache: true)

    assert cached_counts.size == 2
    assert cached_counts.first == 4
    assert cached_counts.last == 5
  end
end
