class InvitationsController < ApplicationController
  before_action :admin_only
  before_action :set_invitation, only: %i[show edit update destroy infiltrate mark_sent]

  # GET /invitations or /invitations.json
  def index
    @invitations = Invitation.order(Arel.sql("IF(rsvp = 'yes', 0, 1), IF(rsvp = 'maybe', 0, 1), IF(rsvp = 'no', 0, 1), IF(name = '', 1, 0), name")).all.to_a
    @invitations.reject!{|i|!i.last_login && i.tagged?('anonymous_invitation')} unless params[:show_anonymous]
  end

  # GET /invitations/1 or /invitations/1.json
  def show
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # GET /invitations/1/edit
  def edit
  end

  def mark_sent
    @invitation.tags ||= []
    @invitation.tags << 'invitation_sent'
    @invitation.save
    flash[:notice] = "Marked-as-sent invitation to #{@invitation.name}"
    redirect_to "/invitations#invitation-#{@invitation.id}"
  end

  # POST /invitations or /invitations.json
  def create
    @invitation = Invitation.new(invitation_params)

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to "/invitations#invitation-#{@invitation.id}", notice: "Invitation was successfully created." }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitations/1 or /invitations/1.json
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to "/invitations#invitation-#{@invitation.id}", notice: "Invitation was successfully updated." }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1 or /invitations/1.json
  def destroy
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to invitations_url, notice: "Invitation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def infiltrate
    session[:infiltrating_from] = @admin.id
    cookies.encrypted.permanent[:invitation] = @invitation.id
    redirect_to root_url
  end

  private
    def admin_only
      @admin = Invitation.find_by(id: cookies.encrypted.permanent[:invitation])
      redirect_to(root_url) unless @admin.tagged? 'admin'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invitation_params
      parsed_params = params.require(:invitation).permit(:name, :notes, :private_notes, :code, :last_login, :emails_list, :phones_list, :tags, :guests_editable_text)
      parsed_params[:tags] = params[:invitation][:tags] # manual hack: shouldn't be needed but is? can't be bothered working out why...
      parsed_params
    end
end
