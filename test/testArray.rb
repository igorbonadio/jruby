require 'test/minirunit'
test_check "Test Array:"
arr = ["zero", "first"]

arr.unshift "second", "third"
test_equal(["second", "third", "zero", "first"], arr)
test_equal(["first"], arr[-1..-1])
test_equal(["first"], arr[3..3])
test_equal([], arr[3..2])
test_equal([], arr[3..1])
test_ok(["third", "zero", "first"] == arr[1..4])
test_ok('["third", "zero", "first"]' == arr[1..4].inspect)

arr << "fourth"

test_ok("fourth" == arr.pop());
test_ok("second" == arr.shift());

test_ok(Array == ["zero", "first"].class)
test_ok("Array" == Array.to_s)
if defined? Java
#  Java::import "org.jruby.test"
#  array = TestHelper::createArray(4)
#  array.each {		# this should not generate an exception
#    |test|
#    true
#  }
#  test_equal(array.length,  4)
end

arr = [1, 2, 3]
arr2 = arr.dup
arr2.reverse!
test_equal([1,2,3], arr)
test_equal([3,2,1], arr2)

test_equal([1,2,3], [1,2,3,1,2,3,1,1,1,2,3,2,1].uniq)

test_equal([1,2,3,4], [[[1], 2], [3, [4]]].flatten)
test_equal(nil, [].flatten!)

arr = []
arr << [[[arr]]]
test_exception(ArgumentError) {
  arr.flatten
}
#test_ok(! arr.empty?, "flatten() shouldn't destroy the list")
#test_exception(ArgumentError) {
#  arr.flatten!
#}

#arr = []
#test_equal([1,2], arr.push(1, 2))
#test_exception(ArgumentError) { arr.push() }

# To test protocol conversion
class IntClass
  def initialize(num); @num = num; end
  def to_int; @num; end; 
end

arr = [1, 2, 3]

index = IntClass.new(1)
arr[index] = 4
test_equal(4, arr[index])
eindex = IntClass.new(2)
arr[index, eindex] = 5
test_equal([1,5], arr)
arr.delete_at(index)
test_equal([1], arr)
arr = arr * eindex
test_equal([1, 1], arr)

# unshifting nothing is valid
test_no_exception { [].unshift(*[]) }
test_no_exception { [].unshift() }

##### Array#[] #####

test_equal([1], Array[1])
test_equal([], Array[])
test_equal([1,2], Array[1,2])

##### insert ####

a = [10, 11]
a.insert(1, 12)
test_equal([10, 12, 11], a)
a = []
a.insert(-1, 10)
test_equal([10], a)
a.insert(-2, 11)
test_equal([11, 10], a)
a = [10]
a.insert(-1, 11)
test_equal([10, 11], a)

##### == #####
class AryTest
  def to_ary; [1,2]; end
end
test_equal([1,2], AryTest.new)

# test that extensions of the base classes are typed correctly
class ArrayExt < Array
end
test_equal(ArrayExt, ArrayExt.new.class)
test_equal(ArrayExt, ArrayExt[:foo, :bar].class)

##### flatten #####
a = [2,[3,[4]]]
test_equal([1,2,3,4],[1,a].flatten)
test_equal([2,[3,[4]]],a)
a = [[1,2,[3,[4],[5]],6,[7,[8]]],9]
test_equal([1,2,3,4,5,6,7,8,9],a.flatten)
test_ok(a.flatten!,"We did flatten")
test_ok(!a.flatten!,"We didn't flatten")

##### splat test #####
class ATest
  def to_a; 1; end
end

proc { |a| test_equal(1, a) }.call(*1)
test_exception(TypeError) { proc { |a| }.call(*ATest.new) }

#### index test ####
class AlwaysEqual
  def ==(arg)
    true
  end
end

array_of_alwaysequal = [AlwaysEqual.new]
# this should pass because index should call AlwaysEqual#== when searching
test_equal(0, array_of_alwaysequal.index("foo"))
test_equal(0, array_of_alwaysequal.rindex("foo"))

#### <=>

test_equal(0, [] <=> [])
test_equal(0, [1] <=> [1])
test_equal(-1, [1] <=> [2])
test_equal(1, [2] <=> [1])
test_equal(1, [1] <=> [])
test_equal(-1, [] <=> [1])

test_equal(0, [1, 1] <=> [1, 1])
test_equal(-1, [1, 1] <=> [1, 2])

test_equal(1, [1,6,1] <=> [1,5,0,1])
test_equal(-1, [1,5,0,1] <=> [1,6,1])

class BadComparator
  def <=>(other)
    "hello"
  end
end

test_equal("hello", [BadComparator.new] <=> [BadComparator.new])

test_exception(SystemStackError) { a = []; a << a; a <=> a }
