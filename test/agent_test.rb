require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::AgentTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }

  context "Agent" do
    before(:each) {|e| Bond.agent.reset }

    test "chooses default mission if no missions match" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.default_mission.expects(:execute)
      tabtab 'blah'
    end

    test "chooses default mission if internal processing fails" do
      complete(:on=>/bling/) {|e| [] }
      Bond.agent.expects(:find_mission).raises
      Bond.agent.default_mission.expects(:execute)
      tabtab('bling')
    end

    test "completes in middle of line" do
      complete(:object=>"Object")
      tabtab(':man.f blah', ':man.f').include?(':man.freeze').should == true
    end

    test "places missions last when declared last" do
      complete(:object=>"Symbol", :place=>:last)
      complete(:method=>"man", :place=>:last) { }
      complete(:on=>/man\s*(.*)/) {|e| e.matched[1] }
      Bond.agent.missions.map {|e| e.class}.should == [Bond::Mission, Bond::Missions::ObjectMission, Bond::Missions::MethodMission]
      tabtab('man ok').should == ['ok']
    end

    test "places mission correctly for a place number" do
      complete(:object=>"Symbol")
      complete(:method=>"man") {}
      complete(:on=>/man\s*(.*)/, :place=>1) {|e| e.matched[1] }
      tabtab('man ok')
      Bond.agent.missions.map {|e| e.class}.should == [Bond::Mission, Bond::Missions::ObjectMission, Bond::Missions::MethodMission]
      tabtab('man ok').should == ['ok']
    end
  end

  context "spy" do
    before(:all) {
      Bond.reset; complete(:on=>/end$/) { [] }; complete(:method=>'the') { %w{spy who loved me} }
      complete(:object=>"Symbol")
    }

    test "detects basic mission" do
      capture_stdout { Bond.spy('the end')}.should =~ /end/
    end

    test "detects object mission" do
      capture_stdout { Bond.spy(':dude.i')}.should =~ /object.*Symbol.*dude\.id/m
    end

    test "detects method mission" do
      capture_stdout { Bond.spy('the ')}.should =~ /method.*the.*loved/m
    end

    test "detects no mission" do
      capture_stdout { Bond.spy('blah')}.should =~ /Doesn't match/
    end
  end
end
