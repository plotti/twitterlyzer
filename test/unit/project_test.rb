require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.create! :name => "Testproject", :description => "Testdescription", :monitor_feeds => true
  end  

  def teardown
    @project = nil
  end
      
  def test_should_graph_net
    Project.graph_net(@project.id)
    
  end
end
