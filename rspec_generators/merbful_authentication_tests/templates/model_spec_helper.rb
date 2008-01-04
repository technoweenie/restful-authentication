module <%= class_name %>SpecHelper
  def valid_<%= singular_name %>_hash
    { :login                  => "daniel",
      :email                  => "daniel@example.com",
      :password               => "sekret",
      :password_confirmation  => "sekret"}
  end
end