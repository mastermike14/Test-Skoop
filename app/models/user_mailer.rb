class UserMailer < ActionMailer::Base

 def post_registration(user)
  recipients  user.email
  from        "Skloop <do-not-reply@skloop.k12.ia.us>"
  subject     "Welcome to Skloop"
  body        :user => user
 end

def message(mail)
    subject     'Skloop Contact/Feedback'
    from        'Skloop <do-not-reply@skloop.waukee.k12.ia.us>'
    recipients  'skloop@waukee.k12.ia.us'
    body        mail
    
  end
 
 def user_message(mail)
  recipients   mail[:email]
  from        "Skloop <do-not-reply@skloop.k12.ia.us>"
  subject     "Thank you for contacting Skloop"
  body        mail
 end


end
