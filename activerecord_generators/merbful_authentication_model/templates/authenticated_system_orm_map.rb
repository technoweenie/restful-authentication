module AuthenticatedSystem
  module OrmMap
    
    def find_authenticated_model_with_id(id)
      <%= class_name %>.find_by_id(id)
    end
    
    def find_authenticated_model_with_remember_token(rt)
      <%= class_name %>.find_by_remember_token(rt)
    end
    
    def find_activated_authenticated_model_with_login(login)
      if <%= class_name %>.instance_methods.include?("activated_at")
        <%= class_name %>.find(:first, :conditions => ["login=? AND activated_at IS NOT NULL", login])
      else
        <%= class_name %>.find_by_login(login)
      end
    end
    
    def find_activated_authenticated_model(activation_code)
      <%= class_name %>.find_by_activation_code(activation_code)
    end  
    
    def find_with_conditions(conditions)
      <%= class_name %>.find(:first, :conditions => conditions)
    end
    
    # A method to assist with specs
    def clear_database_table
      <%= class_name %>.delete_all
    end
  end
  
end