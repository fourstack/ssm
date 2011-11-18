module SimpleStateMachine
  ##
  # Defines state machine transitions
  class StateMachineDefinition

    attr_writer :default_error_state, :state_method, :subject, :decorator,
                :decorator_class

    def decorator
      @decorator ||= decorator_class.new(@subject)
    end

    def decorator_class
      @decorator_class ||= Decorator
    end

    def default_error_state
      @default_error_state && @default_error_state.to_s
    end

    def transitions
      @transitions ||= []
    end

    def define_event event_name, state_transitions
      state_transitions.each do |froms, to|
        [froms].flatten.each do |from|
          add_transition(event_name, from, to)
        end
      end
    end

    def add_transition event_name, from, to
      transition = Transition.new(event_name, from, to)
      transitions << transition
      decorator.decorate(transition)
    end

    def state_method
      @state_method ||= :state
    end

    # Human readable format: old_state.event! => new_state
    def to_s
      transitions.map(&:to_s).join("\n")
    end

    module Inspector
      def begin_states
        from_states - to_states
      end

      def end_states
        to_states - from_states
      end

      def states
        (to_states + from_states).uniq
      end

      private

        def from_states
          to_uniq_sym(sample_transitions.map(&:from))
        end

        def to_states
          to_uniq_sym(sample_transitions.map(&:to))
        end

        def to_uniq_sym(array)
          array.map { |state| state.is_a?(String) ? state.to_sym : state }.uniq
        end

        def sample_transitions
          (@subject || sample_subject).state_machine_definition.send :transitions
        end

        def sample_subject
          self_class = self.class
          sample = Class.new do
            extend SimpleStateMachine::Mountable
            mount_state_machine self_class
          end
          sample
        end
    end
    include Inspector

    module Mountable
      def event event_name, state_transitions
        events << [event_name, state_transitions]
      end

      def events
        @events ||= []
      end

      module InstanceMethods
        def add_events
          self.class.events.each do |event_name, state_transitions|
            define_event event_name, state_transitions
          end
        end
      end
    end
    extend Mountable
    include Mountable::InstanceMethods

  end
end
