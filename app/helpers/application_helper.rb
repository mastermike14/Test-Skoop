# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def active_nav(page)
    page.include?(@active) ? %q{class="active"} : nil
  end

  def get_style_by_agent
	  request.env["HTTP_USER_AGENT"].include?("MSIE") ? %q{ie8} : %q{sstyle}
  end

  ## We are going to use this helper method as a standard
  ## for displaying the notices. A blank, invisible div
  ## will be set for the notices if they are not currently
  ## set. That is for future and current AJAX functions

  def display_flash
    html = []
    flash_to_watch = [:notice, :error]
    flash.each do |key, msg|
      if flash_to_watch.include?(key)
        html << "<div id=\"#{key}\">#{msg}&nbsp;#{hide_message if key == :notice}</div>"  
        flash_to_watch -= [key]
      end
    end
    flash_to_watch.each do |flash|
      html << "<div id=\"#{flash.to_s}\" style=\"display:none\"></div>"    
    end
    return html.join("\n")
  end

end
