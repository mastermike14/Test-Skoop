class Parent < ActiveRecord::Base
  
 has_and_belongs_to_many :users

  validates_presence_of :email, :name
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  def oauth
    @oauth ||= Twitter::OAuth.new(ConsumerConfig['token'], ConsumerConfig['secret'])
  end
  
  def client
    @client ||= begin
      oauth.authorize_from_access(atoken, asecret)
      Twitter::Base.new(oauth)
    end
  end

  def create_following(group)
    begin
      unless self.client.friendship_exists?(self.name, group.name)
        self.client.friendship_create(group.name)
      end
      self.client.enable_notifications(group.name)
    rescue Twitter::General
      self.client.enable_notifications(group.name)
    end
  end


 def follow_child
 end

  def destroy_following(group)
    begin
      self.client.friendship_destroy(group.name)
    rescue Twitter::General
    end
  end

end
