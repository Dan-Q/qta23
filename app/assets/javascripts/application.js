const rsvpForm = document.getElementById('rsvp-form');

const guestsTable = document.querySelector('#rsvp-guests tbody');
function maybeExtendGuestsTable(e){
  if (!guestsTable || !guestsTable.contains(e.target)) return;
  const trs = guestsTable.querySelectorAll('tr');
  let allRowsFull = true;
  trs.forEach(function(tr){
    const guestNameField = tr.querySelector('input[name="guests[][name]"]');
    if(guestNameField.value.trim() === '') allRowsFull = false;
  });
  if(allRowsFull){
    const newRow = trs[0].cloneNode(true);
    newRow.querySelector('input[name="guests[][name]"]').value = '';
    newRow.querySelectorAll('input[type="checkbox"]').forEach(function(checkbox){ checkbox.checked = false; });
    guestsTable.appendChild(newRow);
  }
}

document.addEventListener('change', maybeExtendGuestsTable);
document.addEventListener('keyup', maybeExtendGuestsTable);

function setRSVPStatus(){
  const checkedOption = rsvpOptionList.querySelector('input:checked');
  if(!checkedOption) return;
  rsvpForm.classList.remove('rsvp-yes', 'rsvp-no', 'rsvp-maybe');
  rsvpForm.classList.add(checkedOption.id);  
}

const rsvpOptionList = document.querySelector('#rsvp-option-list');
function maybeRSVPStatusChanged(e){
  if (!rsvpOptionList || !rsvpOptionList.contains(e.target)) return;
  setRSVPStatus();
};
if(rsvpOptionList) retRSVPStatus();

document.addEventListener('change', maybeRSVPStatusChanged);
document.addEventListener('keyup', maybeRSVPStatusChanged);
document.addEventListener('click', maybeRSVPStatusChanged);

if(rsvpForm){
  rsvpForm.addEventListener('submit', function(e){
    const rsvpFormSubmitButton = rsvpForm.querySelector('input[type="submit"]');
    rsvpFormSubmitButton.disabled = true;
    rsvpFormSubmitButton.value = 'Please wait...';
  });
}