class ContactMailer < ActionMailer::Base
  default from: "yaleVoices@app.com"

  def contact_email(contact_form)
    @contact_form = contact_form
    mail(to: "douglas.duhaime@gmail.com", subject: "Sample Email")
  end  

end
