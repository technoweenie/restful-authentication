module AuthenticatedSystem
  module OrmMap
    
    def find_authenticated_model_with_id(id)
      <%= class_name %>.first(:id => id)
    end
    
    def find_authenticated_model_with_remember_token(rt)
      <%= class_name %>.first(:remember_token => rt)
    end
    
    def find_activated_authenticated_model_with_login(login)
      if <%= class_name %>.instance_methods.include?("activated_at")
        <%= class_name %>.first(:login => login, :activated_at.not => nil)
      else
        <%= class_name %>.first(:login => login)
      end
    end
    
    def find_activated_authenticated_model(activation_code)
      <%= class_name %>.first(:activation_code => activation_code)
    end  
    
    def find_with_conditions(conditions)
      <%= class_name %>.first(conditions)
    end
    
    # A method to assist with specs
    def clear_database_table
      <%= class_name %>.auto_migrate!
    end
  end
  
end