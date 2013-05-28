# state_machine.rb

State_machine.rb is a small Ruby mixin that lets you use any Ruby class as a state machine. It is not a gem. Instead, it's meant to be directly included in your project. State_machine.rb requires Ruby 2.0 or later.

## Installing

Copy state_machine.rb into your `$LOAD_PATH`.

## Using state_machine.rb

### Defining your state machine

First require the library

```ruby
require 'state_machine'
```

Then include the `StateMachine` module in your class

```ruby
class MyMachine
  include StateMachine
end
```

You can use `define_transition` to set up a transition.


```ruby
class MyMachine
  define_transition :foo => :bar do
    puts "Transitioning from :foo to :bar"
  end
end
```

This adds `:foo` and `:bar` as valid states and registers the block to be called every time an instance of `MyMachine` in state `:foo` transitions to state `:bar`.

You can set up multiple transitions to use the same transition handler. Handlers are passed two arguments, the old state, and the new state, so you can disambiguate between two transitions that use the same handler.

```ruby
class MyMachine
  define_transition :bar => :baz, :baz => :qux do |from, to|
    puts "Transitioning from #{from.inspect} to #{to.inspect}"
  end
end
```

Transition handlers can return values.

```ruby
class MyMachine
  define_transition :qux => :bozo do
    42
  end
end
```

If you want to add valid states without registering transition handlers, you can use the `state` class method.


```ruby
class MyMachine
  state :qwerty, :dvorak
end
```

You can use `start_state` to set up a default start state for your machine. The argument to `start_state` will be added to the set of valid states. When an instance of your machine is created, the `@state` instance variable will be set _after_ your `initialize` method runs.

```ruby
class MyMachine
  start_state :bozo
end
```

If you want to override the default state set by `start_state`, you can call `initialize_state_machine` in your `initialize` method.

```ruby
class MyMachine
  def initialize
    initialize_state_machine(:foo)

    @greeting = "Hello, world!"
  end
end
```

`initialize_state_machine` requires a valid state as its first and only argument. If `initialize_state_machine` has been called, the default start state set in `start_state` will not be used.

Handlers are evaluated in the context of the instance of your machine, _not_ the machine's class, where they are defined. This is different than how Ruby normally works, but it lets you use instance variables from within your transition handlers, which I think is worth it. If you think of `define_transition` as similar to `define_method`, it all makes sense.


```ruby
class MyMachine
  define_transition :bozo => :buzzard do
    puts @greeting
  end
end
```

### Using your state machine

You can query the current state using the `state` method.

```ruby
>> mm = MyMachine.new
>> mm.state
=> :foo
```

Notice that `:foo` rather than `:bozo` is returned because we called `initialize_state_machine` in our initializer.

You can transition to a new state using the `transition_to` method.

```ruby
>> mm.transition_to(:bar)
Transitioning from :foo to :bar
=> nil
>> mm.transition_to(:baz)
Transitioning from :bar to :baz
=> nil
>> mm.transition_to(:qux)
Transitioning from :bar to :baz
=> nil
```

`transition_to` returns the return value of the transition handler if there is one. Otherwise it returns `nil`.

```ruby
>> mm.transition_to(:bozo)
=> 42
>> mm.transition_to(:qwerty)
=> nil
```

Transitioning to an unknown state will raise an error.

```ruby
>> mm.transition_to(:asdf)
StateMachine::InvalidState: :asdf is an invalid state
```

Finally, proof that instance variables are available inside handlers:

```ruby
>> mm.transition_to(:bozo)
=> nil
>> mm.transition_to(:buzzard)
Hello, world!
=> nil
```

## License

State_machine.rb is copyright David Albert 2013 and is available under the terms of the GNU LGPLv3 (see `COPYING` for more details).

Because you use the library by including it directly in your project, I want to make it clear that including the `state_machine.rb` file in your project constitutes a "Combined Work" and thus your project can still be distributed under whatever terms you desire. Distributing a modified version of the `state_machine.rb` file or any other file included with the library, requires you to distribute the source as well.
