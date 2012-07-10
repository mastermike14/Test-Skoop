class Admin < ActiveRecord::Base
  
  has_many :groups

  def self.authenticate(user, pass)
    auth = ldap_auth(user, pass)
    if auth.class == Person
      u = find_by_uid(user)
      return u
    elsif auth.class == Teacher
        unless admin = find_by_uid(user)
          admin = admin_from_ldap(auth)
          admin.save
        end
        return admin
    else
      return nil
    end
  end

  def own_groups
    case self.access
      when 1
       Group.find(:all, :conditions => ["owner = ?", self.uid])
      when 2
        all_groups_except_main
      when 3
	Group.all
      else
        []
    end  
  end

  def owner?(group_id)
    Group.find(:first, :conditions => ["owner = ? AND id = ?", self.uid, group_id]) or self.access > 1 ? true : false
  end

  def all_groups_except_main
    main_account = 'skloop'
    Group.all - [Group.find(:first, :conditions => ["name = ?", main_account])]
  end

  def full_name
    begin
      "#{self.firstname.capitalize} #{self.lastname.capitalize}"
    rescue
      self.uid
    end
  end

  def twit_id(username, password)
    twitter_httpauth(username, password).id
  end

  protected

  class Person
    attr_accessor :firstname, :lastname, :uid, :access

    def initialize(fname, lname, uid, access=1)
      self.firstname = fname
      self.lastname = lname
      self.uid = uid
      self.access = access
    end
  end

  class Teacher < Person
    attr_accessor :email

    def initialize(superclass, email)
      self.firstname = superclass.firstname
      self.lastname = superclass.lastname
      self.uid = superclass.uid
      self.access = superclass.access
      self.email = email
    end
  end

  def self.ldap_filter(username, instance, attrib=[])
    filter = Net::LDAP::Filter.eq('uid', username)
    instance.search(:filter => filter, :attributes => attrib)[0]
  end

  def self.new_ldap
    ldap_host = "openldap.waukee.k12.ia.us"
    ldap_base = "cn=users,dc=odm,dc=waukee,dc=k12,dc=ia,dc=us"
    ldap = Net::LDAP.new( {:host => ldap_host, :port => 389, :base => ldap_base} )
  end

	def self.ldap_auth(uid, password)
    ldap = self.new_ldap
		result = self.ldap_filter(uid, ldap)
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

  def self.admin_from_ldap(auth)
    Admin.new(
      :firstname => auth.firstname,
      :lastname => auth.lastname,
      :uid => auth.uid,
      :access => auth.access,
      :email => auth.email )
  end

end
