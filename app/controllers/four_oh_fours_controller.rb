class FourOhFoursController < ApplicationController
  def index
    FourOhFour.add_request(request.host, request.path, request.env['HTTP_REFERER'] || '') unless defined?(RAILS_TEST)
    respond_to do |format| 
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 not found"}
      format.all { render :nothing => true, :status => "404 not found"}
    end
  end

end
