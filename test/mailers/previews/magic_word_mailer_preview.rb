# Preview all emails at http://localhost:3000/rails/mailers/magic_word_mailer
class MagicWordMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/magic_word_mailer/remind
  def remind
    MagicWordMailer.remind
  end

end
