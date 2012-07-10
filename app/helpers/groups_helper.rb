module GroupsHelper

  def own_groups
    groups = @user.own_groups.paginate :page => params[:page], :per_page => 8
  end

  def start_group_form(group)
    form_remote_tag(:update => dom_id(group), :url => group_url_path(group), :html => {:id => "group_form_#{group.id}"})
  end

  def group_checkbox(group, method, elements = [])
    elements << start_group_form(group)
    elements << check_box_tag('group[id]', group.id, nil, :checked => (@user.assigned_to?(group) ? 'checked' : false), :onclick => remote_function(:url => group_url_path(group), :before => visual_effect(:puff, "group_check_#{group.id}") + visual_effect(:appear, "spinner_#{group.id}"), :submit => "group_#{group.id}"))
    elements << "</form>"
    return elements.join
  end

  def spinner_image
    image_tag('petal_spinner.gif', :id => "spinner_#{@group.id}", :style => 'display:none')
  end

  def group_url_path(group)
    @user.assigned_to?(group) ? remove_group_path(group) : add_group_path(group)
  end

  def hide_message
    link_to_function "Hide this message", "new Effect.DropOut('notice')"
  end

  def replace_notice
    "<div id=\"notice\">#{flash[:notice]}&nbsp;#{hide_message}</div>"
  end

end
