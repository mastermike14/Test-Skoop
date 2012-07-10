module AdminsHelper

def own_groups
    @user.own_groups.paginate :page => params[:page], :per_page => 8
  end
end
