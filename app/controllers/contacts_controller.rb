class ContactsController < ApplicationController
  allow_unauthenticated_access

  def new
  end

  def create
    if valid_contact_params?
      ContactMailer.contact_email(
        name: params[:name],
        email: params[:email],
        message: params[:message]
      ).deliver_later

      redirect_to contact_path, notice: t("contact.success")
    else
      flash.now[:alert] = t("contact.error")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def valid_contact_params?
    params[:name].present? && params[:email].present? && params[:message].present?
  end
end
