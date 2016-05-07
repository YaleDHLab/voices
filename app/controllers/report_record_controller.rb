class ReportRecordController < ApplicationController

  # POST /report_record
  def create
    @reported_record_id = params[:id]
    @reported_record = Record.find(@reported_record_id)
    @reporting_agent = params[:reporting_agent]

    # on creation of a record deletion request, post to FlaggedRecords
    # a form with cas_user_name and the flagged record id
    @record_flagged = FlaggedRecord.new(flagging_agent: @reporting_agent, flagged_record_id: @reported_record_id)

    if @record_flagged.save
      # send an email to our inbox on save of a contact form
      ContactMailer.report_record(@reported_record, @reporting_agent).deliver
      flash[:success] = "<strong>Success</strong>".html_safe + ": Thank you for contacting us."
      redirect_to root_path
    
    else
      flash[:info] = "<strong>Sorry</strong>".html_safe + ": This request could not be processed; please try again."
      format.html { redirect_to root_path }

    end
  end

end
