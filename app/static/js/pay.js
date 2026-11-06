(function(){
var b=document.getElementById('pay-now');if(!b)return;var csrf=document.querySelector('meta[name=csrf]').content,msg=document.getElementById('pay-msg');
function post(u,body){return fetch(u,{method:'POST',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify(body)}).then(function(r){return r.json().then(function(j){if(!r.ok)throw new Error(j.error||'Request failed');return j})})}
b.addEventListener('click',function(){b.disabled=true;msg.textContent='Preparing secure payment…';
 post('/api/payments/order',{reference:b.dataset.ref}).then(function(o){
  var s=document.createElement('script');s.src='https://checkout.razorpay.com/v1/checkout.js';s.onload=function(){
   var rz=new Razorpay({key:o.key_id,amount:o.amount,currency:o.currency,order_id:o.order_id,name:'Vijay Hospitality',description:'Booking '+o.reference,
    handler:function(r){msg.textContent='Verifying payment…';post('/api/payments/verify',r).then(function(){location.reload()}).catch(function(e){msg.textContent=e.message;b.disabled=false})},
    modal:{ondismiss:function(){b.disabled=false;msg.textContent=''}}});
   rz.on('payment.failed',function(r){post('/api/payments/failed',{order_id:o.order_id,reason:(r.error&&r.error.description)||''});msg.textContent='Payment failed. You can try again.';b.disabled=false});rz.open()};
  s.onerror=function(){msg.textContent='Could not load the payment window.';b.disabled=false};document.body.appendChild(s)
 }).catch(function(e){msg.textContent=e.message;b.disabled=false})});
})();
