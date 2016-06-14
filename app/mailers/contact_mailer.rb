class ContactMailer < ActionMailer::Base
  default from: ENV["GMAIL_USERNAME"]

  def contact_email(contact_form)
    @contact_form = contact_form
    mail(to: ENV["GMAIL_USERNAME"], subject: "VOICES: Contact Us Submission")
  end  

  def report_record(reported_record, reporting_agent)
    @reported_record = reported_record
    @reporting_agent = reporting_agent
    mail(to: ENV["GMAIL_USERNAME"], subject: "VOICES: Report Record")
  end 

end
