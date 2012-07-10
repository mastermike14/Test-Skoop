class Message < ActiveRecord::Base
  attr_accessor :name, :email, :body
  
  validates_presence_of :body, :name
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  def initialize(params)
    @body  = params[:body]
    @email = params[:email]
    @name  = params[:name]
  end 
end
