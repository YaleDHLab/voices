class ContactMailer < ActionMailer::Base
  default from: "yaleVoices@app.com"

  def contact_email(record)
    @record_title = record
    mail(to: "douglas.duhaime@gmail.com", subject: "Sample Email")
  end  

end
