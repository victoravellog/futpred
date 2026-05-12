class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Restablecer tu contraseña - FutPred", to: user.email_address
  end
end
