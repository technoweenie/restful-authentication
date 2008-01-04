require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "<%= singular_name %>_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe <%= model_controller_class_name %> do
  
  include <%= class_name %>SpecHelper
  
  before(:each) do
    <%= class_name %>.clear_database_table
  end
  
  it 'allows signup' do
     lambda do
       create_<%= singular_name %>
       controller.should redirect      
     end.should change(<%= class_name %>, :count).by(1)
   end

   it 'requires login on signup' do
     lambda do
       create_<%= singular_name %>(:login => nil)
       controller.assigns(:<%= singular_name %>).errors.on(:login).should_not be_nil
       controller.should be_successful
     end.should_not change(<%= class_name %>, :count)
   end
    
   it 'requires password on signup' do
     lambda do
       create_<%= singular_name %>(:password => nil)
       controller.assigns(:<%= singular_name %>).errors.on(:password).should_not be_nil
       controller.should be_successful
     end.should_not change(<%= class_name %>, :count)
   end
     
   it 'requires password confirmation on signup' do
     lambda do
       create_<%= singular_name %>(:password_confirmation => nil)
       controller.assigns(:<%= singular_name %>).errors.on(:password_confirmation).should_not be_nil
       controller.should be_successful
     end.should_not change(<%= class_name %>, :count)
   end
   
   it 'requires email on signup' do
     lambda do
       create_<%= singular_name %>(:email => nil)
       controller.assigns(:<%= singular_name %>).errors.on(:email).should_not be_nil
       controller.should be_successful
     end.should_not change(<%= class_name %>, :count)
   end
   
<% if include_activation -%>
   it "should have a route for <%= singular_name %> activation" do
     with_route("/<%= model_controller_plural_name %>/activate/1234") do |params|
       params[:controller].should == "<%= model_controller_class_name %>"
       params[:action].should == "activate" 
       params[:activation_code].should == "1234"    
     end
   end

   it 'activates <%= singular_name %>' do
     create_<%= singular_name %>(:login => "aaron", :password => "test", :password_confirmation => "test")
     @<%= singular_name %> = controller.assigns(:<%= singular_name %>)
     <%= class_name %>.authenticate('aaron', 'test').should be_nil
     get "/<%= model_controller_plural_name %>/activate/1234" 
     controller.should redirect_to("/")
   end

   it 'does not activate <%= singular_name %> without key' do
       get "/<%= model_controller_plural_name %>/activate"
       controller.should be_missing
   end
<% end -%>
     
   def create_<%= singular_name %>(options = {})
     post "/<%= model_controller_plural_name %>", :<%= singular_name %> => valid_<%= singular_name %>_hash.merge(options)
   end
end