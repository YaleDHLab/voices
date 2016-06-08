class ContactFormsController < ApplicationController
  before_action :set_contact_form, only: [:show, :edit, :update, :destroy]

  # GET /contact_forms/new
  def new
    @contact_form = ContactForm.new
  end

  # POST /contact_forms
  # POST /contact_forms.json
  def create
    @contact_form = ContactForm.new(contact_form_params)

    respond_to do |format|
      if @contact_form.save

        # send an email to our inbox on save of a contact form
        ContactMailer.contact_email(@contact_form).deliver_now
        flash[:success] = "<strong>Success</strong>".html_safe + ": Thank you for contacting us."
        format.html { redirect_to root_path }
        format.json { render action: 'show', status: :created, location: @contact_form }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_forms/1
  # DELETE /contact_forms/1.json
  def destroy
    @contact_form.destroy
    respond_to do |format|
      format.html { redirect_to contact_forms_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_form
      @contact_form = ContactForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_form_params
      params.require(:contact_form).permit(:message)
    end
end
