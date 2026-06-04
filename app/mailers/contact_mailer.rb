class ContactMailer < ApplicationMailer
  def contact_email(name:, email:, message:)
    @name = name
    @email = email
    @message = message

    mail(
      to: "contact@futpred.com",
      reply_to: email,
      subject: "FutPred Contact: #{name}"
    )
  end
end
