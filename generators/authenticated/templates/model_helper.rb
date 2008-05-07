module <%= model_controller_class_name %>Helper
  #
  # link to user's page ('<%= table_name %>/1') with user's login.  Their login will appear
  # as the link title (its tooltip) and a 'nickname' class attribute (useful for
  # microformats) will be inserted.
  #
  # Takes options
  # * :content_text => 'Content text in place of <%= file_name %>.login'.  It will be escaped with
  #   the standard h() function.
  #
  # * :content_method => :<%= file_name %>_instance_method_to_call_for_content_text
  #   For instance, you may define a <%= class_name %>#name_or_login method, returning a
  #   user's full name if given, their login otherwise.  In that case you 
  #   could call <%= link_to_<%= file_name %> <%= file_name %>, :content_method => :name_or_login
  #  
  # * :title_method => :<%= file_name %>_instance_method_to_call_for_title_attribute 
  #   Same as :content_method, but used to generate the tag's :title attribute
  #   if none is given.
  #  
  # *  ... any other options will be passed on to link_to
  # 
  # Examples; for 
  #   @barmy = <%= class_name %>.new({:login => 'barmy', :name => 'Cyril Fotheringay-Phipps' ... }) # id => 3@
  #
  #   link_to_<%= file_name %> barmy 
  #   # => <a href="/<%= table_name %>/3" title="barmy" class="nickname">barmy</a>
  #
  #   content_tag :span, :class => :vcard do
  #     link_to_<%= file_name %> barmy, :class => 'fn n' :title_method => :login, :content_method => :name
  #   end
  #   # => <span class="vcard"><a href="/<%= table_name %>/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a></span>
  #
  #   link_to_<%= file_name %> barmy, :content_text => 'Your user page'
  #   # => <a href="/<%= table_name %>/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_<%= file_name %>(<%= file_name %>, options={})
    raise "Invalid <%= file_name %>" if (!<%= file_name %>)
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text) 
    content_text    ||= <%= file_name %>.send(options.delete(:content_method))
    options[:title] ||= <%= file_name %>.send(options.delete(:title_method))
    link_to h(content_text), <%= file_name %>_path(<%= file_name %>), options
  end
  
  #
  # links to signin page using remote ip address as link content
  #
  # Takes option :content_text t
  # The :title attribute (and thus, tooltip) is set to the IP address if none is 
  # specified.
  #
  # Examples; for 
  #   link_to_signin_with_IP
  #   # => <a href="/signin" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_signin_with_IP :content_text => 'Not signed in'
  #   # => <a href="/signin" title="169.69.69.69">Not signed in</a>
  #
  def link_to_signin_with_IP(options={})
    ip_addr           = request.remote_ip
    content_text      = options.delete(:content_text) || ip_addr  
    options[:title] ||= ip_addr
    [:content_method, :title_method].each{|opt| options.delete(opt)} # kill off ignored options from link_to_<%= file_name %>
    link_to h(content_text), signin_path, options
  end 

  #
  # Links to the current <%= file_name %>'s page (using link_to_<%= file_name %>) or to the signin page
  # (using link_to_signin_with_IP).
  #
  def link_to_current_<%= file_name %>(options={})
    if current_<%= file_name %>
      link_to_<%= file_name %> current_<%= file_name %>, options
    else 
      link_to_signin_with_IP options
    end
  end
  
end
