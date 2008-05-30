require File.dirname(__FILE__) + '<%= ('/..'*model_controller_class_nesting_depth) + '/../spec_helper' %>'
describe <%= model_controller_class_name %>Controller do
  describe "route generation" do
    it "should route <%= model_controller_controller_name %>'s 'index' action correctly"   do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'index'              ).should == "/<%= model_controller_routing_path %>"    end
    it "should route <%= model_controller_controller_name %>'s 'new' action correctly"     do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'new'                ).should == "/signup"    end
    it "should route <%= model_controller_controller_name %>'s 'create' action correctly"  do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'create'             ).should == "/register"  end
    it "should route <%= model_controller_controller_name %>'s 'show' action correctly"    do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'show',    :id => '1').should == "/<%= model_controller_routing_path %>/1"    end
    it "should route <%= model_controller_controller_name %>'s 'edit' action correctly"    do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'edit',    :id => '1').should == "/<%= model_controller_routing_path %>/1/edit" end
    it "should route <%= model_controller_controller_name %>'s 'update' action correctly"  do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'update',  :id => '1').should == "/<%= model_controller_routing_path %>/1"    end
    it "should route <%= model_controller_controller_name %>'s 'destroy' action correctly" do      route_for(:controller => '<%= model_controller_controller_name %>', :action => 'destroy', :id => '1').should == "/<%= model_controller_routing_path %>/1"    end
  end

  describe "route recognition" do
    it "should generate params for <%= model_controller_controller_name %>'s index action from GET /<%= model_controller_routing_path %>" do
      params_from(:get, '/<%= model_controller_routing_path %>').should              == {:controller => '<%= model_controller_controller_name %>', :action => 'index'}
      params_from(:get, '/<%= model_controller_routing_path %>.xml').should          == {:controller => '<%= model_controller_controller_name %>', :action => 'index', :format => 'xml'}
      params_from(:get, '/<%= model_controller_routing_path %>.json').should         == {:controller => '<%= model_controller_controller_name %>', :action => 'index', :format => 'json'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s new action from GET /<%= model_controller_routing_path %>" do
      params_from(:get, '/<%= model_controller_routing_path %>/new').should          == {:controller => '<%= model_controller_controller_name %>', :action => 'new'}
      params_from(:get, '/<%= model_controller_routing_path %>/new.xml').should      == {:controller => '<%= model_controller_controller_name %>', :action => 'new', :format => 'xml'}
      params_from(:get, '/<%= model_controller_routing_path %>/new.json').should     == {:controller => '<%= model_controller_controller_name %>', :action => 'new', :format => 'json'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s new action from GET /<%= model_controller_routing_path %>" do
      params_from(:get, '/signup').should             == {:controller => '<%= model_controller_controller_name %>', :action => 'new'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s create action from POST /<%= model_controller_routing_path %>" do
      params_from(:post, '/<%= model_controller_routing_path %>').should             == {:controller => '<%= model_controller_controller_name %>', :action => 'create'}
      params_from(:post, '/<%= model_controller_routing_path %>.xml').should         == {:controller => '<%= model_controller_controller_name %>', :action => 'create', :format => 'xml'}
      params_from(:post, '/<%= model_controller_routing_path %>.json').should        == {:controller => '<%= model_controller_controller_name %>', :action => 'create', :format => 'json'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s create action from POST /<%= model_controller_routing_path %>" do
      params_from(:post, '/register').should          == {:controller => '<%= model_controller_controller_name %>', :action => 'create'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s show action from GET /<%= model_controller_routing_path %>/1" do
      params_from(:get , '/<%= model_controller_routing_path %>/1').should           == {:controller => '<%= model_controller_controller_name %>', :action => 'show', :id => '1'}
      params_from(:get , '/<%= model_controller_routing_path %>/1.xml').should       == {:controller => '<%= model_controller_controller_name %>', :action => 'show', :id => '1', :format => 'xml'}
      params_from(:get , '/<%= model_controller_routing_path %>/1.json').should      == {:controller => '<%= model_controller_controller_name %>', :action => 'show', :id => '1', :format => 'json'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s edit action from GET /<%= model_controller_routing_path %>/1/edit" do
      params_from(:get , '/<%= model_controller_routing_path %>/1/edit').should      == {:controller => '<%= model_controller_controller_name %>', :action => 'edit', :id => '1'}
      params_from(:get , '/<%= model_controller_routing_path %>/1/edit.xml').should  == {:controller => '<%= model_controller_controller_name %>', :action => 'edit', :id => '1', :format => 'xml'}
      params_from(:get , '/<%= model_controller_routing_path %>/1/edit.json').should == {:controller => '<%= model_controller_controller_name %>', :action => 'edit', :id => '1', :format => 'json'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s update action from PUT /<%= model_controller_routing_path %>/1" do
      params_from(:put , '/<%= model_controller_routing_path %>/1').should           == {:controller => '<%= model_controller_controller_name %>', :action => 'update', :id => '1'}
      params_from(:put , '/<%= model_controller_routing_path %>/1.xml').should       == {:controller => '<%= model_controller_controller_name %>', :action => 'update', :id => '1', :format => 'xml'}
      params_from(:put , '/<%= model_controller_routing_path %>/1.json').should      == {:controller => '<%= model_controller_controller_name %>', :action => 'update', :id => '1', :format => 'json'}
    end
    it "should generate params for <%= model_controller_controller_name %>'s destroy action from DELETE /<%= model_controller_routing_path %>/1" do
      params_from(:delete, '/<%= model_controller_routing_path %>/1').should         == {:controller => '<%= model_controller_controller_name %>', :action => 'destroy', :id => '1'}
      params_from(:delete, '/<%= model_controller_routing_path %>/1.xml').should     == {:controller => '<%= model_controller_controller_name %>', :action => 'destroy', :id => '1', :format => 'xml'}
      params_from(:delete, '/<%= model_controller_routing_path %>/1.json').should    == {:controller => '<%= model_controller_controller_name %>', :action => 'destroy', :id => '1', :format => 'json'}
    end
  end

  describe "named routing" do
    before(:each) do
      get :new
    end
    it "should route <%= model_controller_routing_name %>_path() correctly" do
      <%= model_controller_routing_name %>_path().should                                       == "/<%= model_controller_routing_path %>"
      formatted_<%= model_controller_routing_name %>_path(:format => 'xml').should             == "/<%= model_controller_routing_path %>.xml"
      formatted_<%= model_controller_routing_name %>_path(:format => 'json').should            == "/<%= model_controller_routing_path %>.json"
    end
    it "should route new_<%= model_controller_routing_name.singularize %>_path() correctly" do
      new_<%= model_controller_routing_name.singularize %>_path().should                                    == "/<%= model_controller_routing_path %>/new"
      formatted_new_<%= model_controller_routing_name.singularize %>_path(:format => 'xml').should          == "/<%= model_controller_routing_path %>/new.xml"
      formatted_new_<%= model_controller_routing_name.singularize %>_path(:format => 'json').should         == "/<%= model_controller_routing_path %>/new.json"
    end
    it "should route <%= model_controller_routing_name.singularize %>_(:id => '1') correctly" do
      <%= model_controller_routing_name.singularize %>_path(:id => '1').should == "/<%= model_controller_routing_path %>/1"
      formatted_<%= model_controller_routing_name.singularize %>_path(:id => '1', :format => 'xml').should  == "/<%= model_controller_routing_path %>/1.xml"
      formatted_<%= model_controller_routing_name.singularize %>_path(:id => '1', :format => 'json').should == "/<%= model_controller_routing_path %>/1.json"
    end
    it "should route edit_<%= model_controller_routing_name.singularize %>_path(:id => '1') correctly" do
      edit_<%= model_controller_routing_name.singularize %>_path(:id => '1').should                         == "/<%= model_controller_routing_path %>/1/edit"
    end
    it "should route signup_path() correctly" do
      signup_path().should                                      == "/signup"
    end
    it "should route signup_path() correctly" do
      register_path().should                                    == "/register"
    end
  end
end
