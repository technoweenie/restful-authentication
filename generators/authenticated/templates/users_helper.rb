module <%= model_controller_class_name %>Helper

  #
  # Use this to wrap view elements that the visitor can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%%= if_authorized?(:index,   <%= class_name %>)  do link_to('List all <%= model_name %>s', <%= model_name %>s_path) end %> |
  # <%%= if_authorized?(:edit,    @<%= model_name %>) do link_to('Edit this <%= model_name %>', edit_<%= model_name %>_path) end %> |
  # <%%= if_authorized?(:destroy, @<%= model_name %>) do link_to 'Destroy', @<%= model_name %>, :confirm => 'Are you sure?', :method => :delete end %>
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to <%= model_name %>'s page ('<%= model_controller_routing_path %>/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of <%= model_name %>.login', escaped with
  #   the standard h() function.
  # * :content_method => :<%= model_name %>_instance_method_to_call_for_content_text
  # * :title_method => :<%= model_name %>_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_<%= model_name %> @<%= model_name %>
  #   # => <a href="/<%= model_controller_routing_path %>/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_<%= model_name %> <%= model_name %>, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, <%= model_name %>.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/<%= model_controller_routing_path %>/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_<%= model_name %> @<%= model_name %>, :content_text => 'Your <%= model_name %> page'
  #   # => <a href="/<%= model_controller_routing_path %>/3" title="barmy" class="nickname">Your <%= model_name %> page</a>
  #
  def link_to_<%= model_name %>(<%= model_name %>, options={})
    raise "Invalid <%= model_name %>" unless <%= model_name %>
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= <%= model_name %>.send(options.delete(:content_method))
    options[:title] ||= <%= model_name %>.send(options.delete(:title_method))
    link_to h(content_text), <%= model_name %>_path(<%= model_name %>), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current visitor's page (using link_to_<%= model_name %>) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={})
    if current_user
      link_to_<%= model_name %> current_user, options
    else
      content_text = options.delete(:content_text) || 'not signed in'
      # kill ignored options from link_to_<%= model_name %>
      [:content_method, :title_method].each{|opt| options.delete(opt)}
      link_to_login_with_IP content_text, options
    end
  end

end
