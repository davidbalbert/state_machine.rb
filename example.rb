require './state_machine'

class FooMachine
  include StateMachine

  start_state :foo

  define_transition :foo => :bar, :bar => :baz do |from, to|
    puts "#{from.inspect} to #{to.inspect}"
  end

  define_transition :baz => :qux do
    puts @ivar
  end

  define_transition :qux => :bozo do
    42
  end

  def initialize
    @ivar = "hi there"
  end
end

fm = FooMachine.new
fm.transition_to(:bar)
fm.transition_to(:baz)
fm.transition_to(:qux)
puts fm.transition_to(:bozo)
