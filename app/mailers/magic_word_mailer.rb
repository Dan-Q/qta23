class MagicWordMailer < ApplicationMailer
  default from: ENV['SMTP_USERNAME']

  def remind
    @magic_word = params[:magic_word]
    delivery_options = { user_name: ENV['SMTP_USERNAME'],
                         password: ENV['SMTP_PASSWORD'],
                         address: ENV['SMTP_SERVER'] }
    mail(to: params[:email],
         subject: 'Summer Party at The Green 2023: Magic Word Reminder',
         delivery_method_options: delivery_options)
  end
end
