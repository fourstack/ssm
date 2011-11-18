require 'spec_helper'

describe SimpleStateMachine::Tools::Graphviz do

  before do
    @klass = Class.new do
      extend SimpleStateMachine
      def initialize(state = 'state1')
        @state = state
      end
      event :event1, :state1 => :state2, :state2 => :state3
    end
    @smd = @klass.state_machine_definition
  end

  describe "#to_graphviz_dot" do
    it "converts to graphviz dot format" do
      @smd.to_graphviz_dot.should ==  %("state1"->"state2"[label=event1];"state2"->"state3"[label=event1])
    end
  end

  describe "#google_chart_url" do
    it "shows the state and event dependencies as a Google chart" do
      @smd.google_chart_url.should == "http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape @smd.to_graphviz_dot}}"
    end
  end
end


