class ContactMailer < ActionMailer::Base
  default from: "yaleVoices@app.com"

  def contact_email(contact_form)
    @contact_form = contact_form
    mail(to: "douglas.duhaime@gmail.com", subject: "Sample Email")
  end  

  def report_record(reported_record, reporting_agent)
    @reported_record = reported_record
    @reporting_agent = reporting_agent
    mail(to: "douglas.duhaime@gmail.com", subject: "VOICES: Report Record")
  end 

end
