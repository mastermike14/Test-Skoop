require 'net/ldap'

module Ldap

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

  def ldap_test(uid)
    ldap = new_ldap
    result = ldap_filter(uid, ldap)
    p result
  end

  ## Test methods below

  def ldap_exists2?(f, l, u)
    true
  end

end
