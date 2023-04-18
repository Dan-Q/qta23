require "application_system_test_case"

class InvitationsTest < ApplicationSystemTestCase
  setup do
    @invitation = invitations(:one)
  end

  test "visiting the index" do
    visit invitations_url
    assert_selector "h1", text: "Invitations"
  end

  test "should create invitation" do
    visit invitations_url
    click_on "New invitation"

    fill_in "Code", with: @invitation.code
    fill_in "Emails", with: @invitation.emails
    fill_in "Guests", with: @invitation.guests
    fill_in "Last login", with: @invitation.last_login
    fill_in "Name", with: @invitation.name
    fill_in "Notes", with: @invitation.notes
    fill_in "Phones", with: @invitation.phones
    fill_in "Private notes", with: @invitation.private_notes
    click_on "Create Invitation"

    assert_text "Invitation was successfully created"
    click_on "Back"
  end

  test "should update Invitation" do
    visit invitation_url(@invitation)
    click_on "Edit this invitation", match: :first

    fill_in "Code", with: @invitation.code
    fill_in "Emails", with: @invitation.emails
    fill_in "Guests", with: @invitation.guests
    fill_in "Last login", with: @invitation.last_login
    fill_in "Name", with: @invitation.name
    fill_in "Notes", with: @invitation.notes
    fill_in "Phones", with: @invitation.phones
    fill_in "Private notes", with: @invitation.private_notes
    click_on "Update Invitation"

    assert_text "Invitation was successfully updated"
    click_on "Back"
  end

  test "should destroy Invitation" do
    visit invitation_url(@invitation)
    click_on "Destroy this invitation", match: :first

    assert_text "Invitation was successfully destroyed"
  end
end
