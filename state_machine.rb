#  This program is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
#  License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

      nil
    end

    def state(*new_states)
      new_states.each do |state|
        states << state
      end

      nil
    end

    def start_state(state = nil)
      if state
        states << state
        @start_state = state

        nil
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
