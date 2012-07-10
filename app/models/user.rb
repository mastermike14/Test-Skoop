require 'net/ldap'

class User < ActiveRecord::Base

  include AASM

  has_and_belongs_to_many :groups
  has_many :parents, :dependent => :destroy

  validates_presence_of :uid, :if => :valid_state_uid
  validates_uniqueness_of :uid, :if => :valid_state_uid
  validates_presence_of :firstname, :lastname, :if => :valid_state_name
  validates_presence_of :email, :if => :valid_state_email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => :valid_state_email

  aasm_column :aasm_state
  aasm_initial_state :first

  def self.find_by_twitter(username)
    find(:first, :conditions => ["username = ?", username])
  end

  def self.find_by_uid(username)
    find(:first, :conditions => ["uid = ?", username])
  end

  def unassigned_groups
	  Group.find(:all) - self.groups
  end

  def assigned_to?(group)
	  self.groups.include?(group)
  end

  def full_name
    "#{self.firstname.capitalize} #{self.lastname.capitalize}"
  end

	def ldap_auth(uid, password)
    ldap = new_ldap
		result = ldap_filter(uid, ldap)
		begin
  		username = result.dn
      person = Admin::Person.new(result.givenname[0], result.sn[0], uid)
  		unless result["mail"].to_s.empty?
  			person = Admin::Teacher.new(person, result.mail[0])
        person.access = 1
      end
      ldap.auth(username, password)
  		ldap.bind ? person : nil
    rescue NoMethodError
      nil
    end
	end

  def authorized?
    atoken.present? && asecret.present?
  end

  def oauth
    @oauth ||= Twitter::OAuth.new(ConsumerConfig['token'], ConsumerConfig['secret'])
  end

  delegate :request_token, :access_token, :authorize_from_request, :to => :oauth
  
  def client
    @client ||= begin
      oauth.authorize_from_access(atoken, asecret)
      Twitter::Base.new(oauth)
    end
  end

  def create_following(group)
    begin
      unless self.client.friendship_exists?(self.username, group.name)
        self.client.friendship_create(group.name)
        group.client.friendship_create(self.username)
      end
      self.groups << group
      self.client.enable_notifications(group.name)
       group.client.friendship_create(self.username)
    rescue Twitter::General
      self.groups << group
      self.client.enable_notifications(group.name)
      group.client.friendship_create(self.username)
    end
  end

  def destroy_following(group)
      self.client.friendship_destroy(group.name)
      self.groups.delete(group)
      group.client.friendship_destroy(self.username)
    rescue Twitter::General
      self.groups.delete(group)
      group.client.friendship_destroy(self.username)
  end

  ## Methods for transitioning between steps on signup wizard

  aasm_state :first, :after => :current_form
  aasm_state :uid, :after => :current_form
  aasm_state :name, :after => :current_form
  aasm_state :email, :after => :current_form
  aasm_state :info, :after => :current_Form
  aasm_state :terms, :after => :current_form

  def aasm_state
    @aasm_state ||= "first"
  end

  def aasm_state=(state)
    @aasm_state=state
  end

  def aasm_direction(direction)
    form_order = %w{first terms uid name email info}
    case direction
      when 'next'
        @aasm_state = form_order[form_order.index(@aasm_state)+1]
      when 'previous'
        @aasm_state = form_order[form_order.index(@aasm_state)-1]
    end
  end

  def valid_state_name
    aasm_state == 'name'
  end

  def valid_state_uid
    aasm_state == 'uid'
  end

  def valid_state_email
    aasm_state == 'email'
  end

  def current_form
    @current_form ||= self.aasm_current_state
  end

  protected

  ## Custom validation methods - these validate twitter and ldap credentials

  def validate
    unless valid_state_uid
    unless errors.on(:firstname) or errors.on(:lastname) or errors.on(:uid)
      unless ldap_exists?(self.firstname, self.lastname, self.uid)
        errors.add(:autherror, "your first and last name do not match the user id entered. If your think your details are correct you may have entered your user id wrong. Press previous to correct")
      end
    end
    end
  end

  ## OAuth methods

  def ldap_filter(username, instance, attrib=[])
    filter = Net::LDAP::Filter.eq('uid', username)
    instance.search(:filter => filter, :attributes => attrib)[0]
  end

  def new_ldap
    ldap_host = "openldap.waukee.k12.ia.us"
    ldap_base = "cn=users,dc=odm,dc=waukee,dc=k12,dc=ia,dc=us"
    ldap = Net::LDAP.new( {:host => ldap_host, :port => 389, :base => ldap_base} )
  end

  ## LDAP method checks if  uid matches first and last name 

	def ldap_exists?(firstname, lastname, uid)
    ldap = new_ldap
		result = ldap_filter(uid, ldap)
    begin
		  result.givenname.to_s.downcase == firstname and result.sn.to_s.downcase == lastname ? true : false
		rescue NoMethodError
      false
    end
	end

  ## Setter methods to force lowercase entries

  def username=(user)
    write_attribute(:username, user.downcase)
  end

  def firstname=(fname)
    write_attribute(:firstname, fname.downcase)
  end

  def lastname=(lname)
    write_attribute(:lastname, lname.downcase)
  end

end
