class MainController < ApplicationController
  before_action :check_if_logged_in
  before_action :must_be_logged_in, only: [:rsvp, :ics]

  def index
    render @invitation ? 'invitation' : 'index'
  end

  def login
    if (identity = Invitation.find_by(code: params[:code]))
      identity.touch(:last_login)
      cookies.encrypted[:invitation] = { value: identity.id, httponly: true, expires: 6.months.from_now, same_site: :lax }
    else
      if request.post?
        flash[:notice] = "That magic word wasn't recognised. Do you need to take a spelling lesson?"
      end
    end
    redirect_to root_url
  end

  def logout
    if session[:infiltrating_from]
      # end infiltration
      cookies.encrypted.permanent[:invitation] = session[:infiltrating_from]
      session[:infiltrating_from] = nil
      redirect_to '/invitations'
      return
    end
    # actually log out
    cookies.delete(:invitation)
    redirect_to root_url
  end

  def rsvp
    # Update each param with a bit of logic which ought to be in the model but who can be bothered, right?
    # These are some real hacky workaround to strong parameters just because I was lazy!
    @invitation.rsvp = params[:rsvp]
    @invitation.guests = params[:guests].map{|g| { name: g[:name], child: !!g[:child], vegetarian: !!g[:vegetarian] } }.reject{|g| g[:name].blank? }
    @invitation.emails = params[:emails].map(&:to_s).reject(&:blank?)
    @invitation.phones = params[:phones].map(&:to_s).reject(&:blank?)
    (@invitation.tags ||= []) << 'camping' if params[:camping]
    @invitation.notes = params[:notes]
    @invitation.tags.uniq!
    if !@invitation.save
      flash[:notice] = "Something went wrong while recording your RSVP. <a href=\"#contact\">Get in touch</a> and let us know!"
    elsif @invitation.rsvp == 'yes'
      if @invitation.guests.length > 0
        flash[:notice] = "We're glad to hear that you're coming. Looking forward to seeing you there!"
      else
        flash[:notice] = "Thanks for letting us know you're coming. If you could update the list of guest names so we know how many people to expect, we'd appreciate it!"
      end
    elsif @invitation.rsvp == 'maybe'
      flash[:notice] = "Thanks for letting us know. We'll get in touch closer to the time to remind you to RSVP."
    elsif @invitation.rsvp == 'no'
      flash[:notice] = "Sorry to hear you can't join us. If your circumstances change, come back to this page and let us know."
    end
    redirect_to root_url
  end

  def remind
    if params[:contact] =~ /@/
      # treat as email
      if invitation = Invitation.where('emails LIKE ? OR emails LIKE ?', "%- #{params[:contact]}%", "%- '#{params[:contact]}'%").first
        MagicWordMailer.with(magic_word: invitation.code, email: params[:contact]).remind.deliver_now
        flash[:notice] = "We've emailed you a fresh magic word. If you don't see it in a few minutes, check your spam folder!"
      else
        flash[:notice] = "That email address wasn't recognised. Is there perhaps a different email address we might use for you?"
      end
    elsif params[:contact] =~ /^[0-9 \(\)\-]+$/
      # treat as phone number
      phone = Invitation.standardise_phone_number(params[:contact])
      if invitation = Invitation.where('phones LIKE ? OR phones LIKE ?', "- %#{phone}%", "%- '#{phone}'%").first
        nexmo = Vonage::Client.new(
          api_key: ENV['VONAGE_API_KEY'],
          api_secret: ENV['VONAGE_API_SECRET']
        )
        nexmo.sms.send(
          from: 'qta23.uk',
          to: phone.gsub(/^07/, '447'),
          text: "Your magic word for logging into qta23.uk is:\n#{invitation.code}"
        )
        flash[:notice] = "Okay: we're sending a text message to your phone with a reminder of your magic word!"
      else
        flash[:notice] = "That phone number wasn't recognised. Is there perhaps a different phone number we might use for you?"
      end
    else
      flash[:notice] = "Sorry, that didn't look like an email address OR a phone number."
    end
    redirect_to root_url
  end

  def ics
    response.headers['Content-Type'] = 'text/calendar'
    response.headers['Content-Disposition'] = 'attachment; filename="Summer Party at The Green 2023.ics"'
    render plain: "BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nDTSTART:20230819T140000Z\nDTEND:20230819T223000Z\nSUMMARY:Summer Party at The Green\nDESCRIPTION:https://qta23.uk/ - log in using magic word \"#{@invitation.code}\"\nLOCATION:The Green, Eynsham Road, Sutton, OX29 5RZ\nEND:VEVENT\nEND:VCALENDAR\n"
  end

  protected

  def check_if_logged_in
    @invitation = Invitation.find_by(id: cookies.encrypted.permanent[:invitation])
  end

  def must_be_logged_in
    return if @invitation

    redirect_to action: :login
  end
end
