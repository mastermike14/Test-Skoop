module UsersHelper
  def form_template(state)
    "users/#{state.underscore}"
  end
end
