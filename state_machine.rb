require 'set'

module StateMachine
  class InvalidState < StandardError; end
  class AlreadyInitialized < StandardError; end

  def self.included(klass)
    klass.extend ClassMethods
    klass.send(:prepend, Initializer)
  end

  module ClassMethods
    def define_transition(new_transitions, &handler)
      new_transitions.each do |from, to|
        states << from
        states << to

        transitions[[from, to]] = handler
      end
    end

    def start_state(state = nil)
      if state
        states << state
        @start_state = state
      else
        @start_state
      end
    end

    def transitions
      @transitions ||= {}
    end

    def states
      @states ||= Set.new
    end
  end

  module Initializer
    def initialize(*args)
      super(*args)

      if @state.nil? && self.class.start_state
        @state = self.class.start_state
      end
    end
  end

  def transitions
    self.class.transitions
  end

  def states
    self.class.states
  end

  def state
    @state
  end

  def transition_to(new_state)
    unless states.include?(new_state)
      raise InvalidState, "#{new_state.inspect} is an invalid state"
    end

    old_state = @state
    @state = new_state

    if transitions[[old_state, new_state]]
      instance_exec(old_state, new_state, &transitions[[old_state, new_state]])
    end
  end

  def initialize_state_machine(state)
    if @state
      raise AlreadyInitialized, "This state machine has already been initialized"
    end

    unless states.include?(state)
      raise InvalidState, "#{state.inspect} is an invalid state"
    end

    @state = state
  end
end

if __FILE__ == $0
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
end
