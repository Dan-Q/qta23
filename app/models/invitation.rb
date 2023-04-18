class Invitation < ApplicationRecord
  serialize :emails, Array
  serialize :phones, Array
  serialize :guests, Array
  serialize :tags, Array

  validates :rsvp, inclusion: { in: %w[yes no maybe], allow_nil: true }

  before_save :standardise_phone_numbers

  # Tags which have meaning, so far:
  KNOWN_TAGS = {
    'admin' => "Can manage the party, invitations, etc. Don't give this out willy-nilly.",
    'local' => "Don't show the 'wide area' map. Discourage travel by car.",
    'friend of annabel' => 'Substitutes the intro message to one that introduces the hosts as "Annabel and her family".',
    'friend of john' => 'Substitutes the intro message to one that introduces the hosts as "John and his family".',
    'camping' => 'Invitee has indicated that they intend to camp.',
    'invitation_sent' => 'Invitation has been sent. Help keep track of who we\'ve send a message to already!',
    '3r' => "They're a Three Ringer!",
    'abnib' => "They're an Abnib person!",
    'resident' => "Some or all of them usually live at The Green!",
    'attended_2022' => 'Did they come last year?',
  }

  def tagged?(tag)
    (tags || []).include?(tag)
  end

  def standardise_phone_numbers
    (self.phones ||= []).map!{|p| Invitation::standardise_phone_number(p) }
  end

  def emails_list
    (self.emails || []).join("\n")
  end

  def emails_list=(new_emails)
    self.emails = new_emails.split("\n").map(&:strip).reject(&:blank?)
  end

  def phones_list
    (self.phones || []).join("\n")
  end

  def phones_list=(new_phones)
    self.phones = new_phones.split("\n").map(&:strip).reject(&:blank?)
  end

  def guests_json
    (self.guests || []).to_json
  end

  def guests_json=(new_json)
    self.guests = JSON.parse(new_json)
  end

  def guests_editable_text
    (self.guests || []).map{|g|
      suffixes = []
      suffixes << ':c' if g[:child]
      suffixes << ':v' if g[:vegetarian]
      "#{g[:name]}#{suffixes.join('')}"
    }.join("\n")
  end

  def guests_editable_text=(new_text)
    self.guests = new_text.split("\n").map(&:strip).reject(&:blank?).map{|g|
      guest = { child: false, vegetarian: false }
      while g =~ /^(.+):([cv])$/
        guest[:child] = true if $2 == 'c'
        guest[:vegetarian] = true if $2 == 'v'
        g = $1
      end
      guest[:name] = g
      guest
    }
  end

  def self.standardise_phone_number(phone)
    phone.gsub(/[^0-9]/, '')
  end
end
