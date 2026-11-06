(function(){
var open=document.getElementById('chat-open'),box=document.getElementById('chat'),log=document.getElementById('chat-log'),form=document.getElementById('chat-form'),inp=document.getElementById('chat-in');
if(!open)return;var csrf=document.querySelector('meta[name=csrf]').content,busy=false,started=false;
function add(t,c){var d=document.createElement('div');d.className='cm '+c;d.textContent=t;log.appendChild(d);log.scrollTop=log.scrollHeight;return d}
function toggle(){box.classList.toggle('open');open.setAttribute('aria-expanded',box.classList.contains('open'));
 if(box.classList.contains('open')&&!started){started=true;add('Welcome to Vijay Hospitality! I can check room availability and make a booking for you. When would you like to stay?','b');inp.focus()}}
open.addEventListener('click',toggle);document.getElementById('chat-close').addEventListener('click',toggle);
form.addEventListener('submit',function(e){e.preventDefault();var m=inp.value.trim();if(!m||busy)return;inp.value='';add(m,'u');busy=true;var w=add('Typing…','b');
 fetch('/api/chat',{method:'POST',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify({message:m})}).then(function(r){return r.json()}).then(function(j){
  w.textContent=j.reply||j.error||'Sorry, something went wrong.';if(j.booking){var a=document.createElement('a');a.href='/booking/'+j.booking;a.textContent='View booking '+j.booking;a.style.display='block';a.style.marginTop='6px';w.appendChild(a)}
 }).catch(function(){w.textContent='Connection problem. Please try again.'}).finally(function(){busy=false;log.scrollTop=log.scrollHeight})});
})();
