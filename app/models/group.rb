require 'timeout'

class Group < ActiveRecord::Base

  has_and_belongs_to_many :users
  belongs_to :admins

  validates_presence_of :name, :desc, :owner
  validates_uniqueness_of :name, :message => "That twitter group account is already in use"

  def fullname_from_owner(owner)
    a = Admin.find(:first, :conditions => ["uid = ?", owner])
    a.nil? ? owner : a.full_name
  end

  def reset
    @users = self.users.all
    @users.each do |user|
      begin
        user.client.friendship_destroy(self.name)
      rescue Twitter::General
        next
      rescue
        Timeout::timeout(5) do        
          redo
        end
        rescue Timeout::Error
          next
      end
    end
    self.users.clear
  end

  def authorized?
    atoken.present? && asecret.present?
  end

  def oauth
    @oauth ||= Twitter::OAuth.new(ConsumerConfig['token'], ConsumerConfig['secret'])
  end

  def self.find_by_name(name)
    find(:first, :conditions => ["name = ?", name])
  end

  delegate :request_token, :access_token, :authorize_from_request, :to => :oauth
  
  def client
    @client ||= begin
      oauth.authorize_from_access(atoken, asecret)
      Twitter::Base.new(oauth)
    end
  end

  
  def self.search(search, page)
    if search
      paginate :per_page => 8, :page => page,
               :conditions => ['`desc` LIKE ?', "%#{search}%"]
    else
      find(:all)
    end
  end
end
