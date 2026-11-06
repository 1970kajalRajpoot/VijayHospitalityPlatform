CREATE TABLE users(id INTEGER PRIMARY KEY,email TEXT NOT NULL UNIQUE,name TEXT NOT NULL,password_hash TEXT NOT NULL,
 role TEXT NOT NULL CHECK(role IN('owner','admin','receptionist')),active INTEGER NOT NULL DEFAULT 1,
 failed_logins INTEGER NOT NULL DEFAULT 0,locked_until TEXT,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE properties(id INTEGER PRIMARY KEY,slug TEXT NOT NULL UNIQUE,name TEXT NOT NULL,kind TEXT NOT NULL,address TEXT,phone TEXT,email TEXT,
 whatsapp TEXT,map_url TEXT,description TEXT,active INTEGER NOT NULL DEFAULT 1);
CREATE TABLE room_categories(id INTEGER PRIMARY KEY,property_id INTEGER NOT NULL REFERENCES properties(id),name TEXT NOT NULL,ac INTEGER NOT NULL DEFAULT 0,
 description TEXT,base_price_paise INTEGER NOT NULL DEFAULT 0 CHECK(base_price_paise>=0),max_adults INTEGER NOT NULL DEFAULT 2 CHECK(max_adults>=1),
 max_children INTEGER NOT NULL DEFAULT 1 CHECK(max_children>=0),image TEXT,active INTEGER NOT NULL DEFAULT 1,UNIQUE(property_id,name));
CREATE TABLE rooms(id INTEGER PRIMARY KEY,property_id INTEGER NOT NULL REFERENCES properties(id),category_id INTEGER NOT NULL REFERENCES room_categories(id),
 number TEXT NOT NULL,floor TEXT,price_override_paise INTEGER CHECK(price_override_paise IS NULL OR price_override_paise>0),description TEXT,
 status TEXT NOT NULL DEFAULT 'active' CHECK(status IN('active','inactive')),UNIQUE(property_id,number));
CREATE TABLE amenities(id INTEGER PRIMARY KEY,name TEXT NOT NULL UNIQUE);
CREATE TABLE room_amenities(room_id INTEGER NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,amenity_id INTEGER NOT NULL REFERENCES amenities(id) ON DELETE CASCADE,PRIMARY KEY(room_id,amenity_id));
CREATE TABLE room_images(id INTEGER PRIMARY KEY,room_id INTEGER NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,path TEXT NOT NULL,alt TEXT,sort INTEGER NOT NULL DEFAULT 0);
CREATE TABLE pricing_rules(id INTEGER PRIMARY KEY,category_id INTEGER NOT NULL REFERENCES room_categories(id) ON DELETE CASCADE,label TEXT,
 start_date TEXT NOT NULL,end_date TEXT NOT NULL,price_paise INTEGER NOT NULL CHECK(price_paise>0),CHECK(end_date>=start_date));
CREATE TABLE customers(id INTEGER PRIMARY KEY,name TEXT NOT NULL,phone TEXT NOT NULL UNIQUE,email TEXT,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE reservations(id INTEGER PRIMARY KEY,ref TEXT NOT NULL UNIQUE,customer_id INTEGER NOT NULL REFERENCES customers(id),room_id INTEGER NOT NULL REFERENCES rooms(id),
 check_in TEXT NOT NULL,check_out TEXT NOT NULL,adults INTEGER NOT NULL CHECK(adults>=1),children INTEGER NOT NULL DEFAULT 0 CHECK(children>=0),nights INTEGER NOT NULL CHECK(nights>=1),
 room_total_paise INTEGER NOT NULL,tax_paise INTEGER NOT NULL,total_paise INTEGER NOT NULL,
 status TEXT NOT NULL CHECK(status IN('pending','confirmed','checked_in','checked_out','cancelled','no_show','expired')),
 source TEXT NOT NULL CHECK(source IN('web','ai','walk-in','phone')),notes TEXT,hold_expires_at TEXT,created_by INTEGER REFERENCES users(id),
 created_at TEXT NOT NULL,updated_at TEXT NOT NULL,CHECK(check_out>check_in));
CREATE INDEX ix_res_dates ON reservations(check_in,check_out);CREATE INDEX ix_res_status ON reservations(status);CREATE INDEX ix_res_cust ON reservations(customer_id);
CREATE TABLE room_nights(room_id INTEGER NOT NULL REFERENCES rooms(id),night TEXT NOT NULL,reservation_id INTEGER REFERENCES reservations(id) ON DELETE CASCADE,reason TEXT,
 PRIMARY KEY(room_id,night));
CREATE INDEX ix_rn_res ON room_nights(reservation_id);
CREATE TABLE payments(id INTEGER PRIMARY KEY,reservation_id INTEGER NOT NULL REFERENCES reservations(id),method TEXT NOT NULL CHECK(method IN('razorpay','cash','upi','card','bank')),
 amount_paise INTEGER NOT NULL CHECK(amount_paise>0),status TEXT NOT NULL CHECK(status IN('created','paid','failed','refunded','partially_refunded')),
 gateway_order_id TEXT UNIQUE,gateway_payment_id TEXT UNIQUE,reference TEXT,refunded_paise INTEGER NOT NULL DEFAULT 0 CHECK(refunded_paise>=0),
 created_by INTEGER REFERENCES users(id),created_at TEXT NOT NULL,paid_at TEXT);
CREATE INDEX ix_pay_res ON payments(reservation_id);
CREATE TABLE transactions(id INTEGER PRIMARY KEY,payment_id INTEGER NOT NULL REFERENCES payments(id),kind TEXT NOT NULL CHECK(kind IN('order','capture','failure','refund','webhook')),
 amount_paise INTEGER,gateway_ref TEXT,payload TEXT,created_at TEXT NOT NULL);
CREATE TABLE checkins(id INTEGER PRIMARY KEY,reservation_id INTEGER NOT NULL UNIQUE REFERENCES reservations(id),room_id INTEGER NOT NULL REFERENCES rooms(id),at TEXT NOT NULL,
 by_user INTEGER REFERENCES users(id),id_proof_type TEXT,id_proof_last4 TEXT,note TEXT);
CREATE TABLE checkouts(id INTEGER PRIMARY KEY,reservation_id INTEGER NOT NULL UNIQUE REFERENCES reservations(id),at TEXT NOT NULL,by_user INTEGER REFERENCES users(id),balance_paise INTEGER NOT NULL DEFAULT 0);
CREATE TABLE cancellations(id INTEGER PRIMARY KEY,reservation_id INTEGER NOT NULL UNIQUE REFERENCES reservations(id),reason TEXT,refund_due_paise INTEGER NOT NULL DEFAULT 0,
 by_user INTEGER REFERENCES users(id),by_customer INTEGER NOT NULL DEFAULT 0,at TEXT NOT NULL);
CREATE TABLE notifications(id INTEGER PRIMARY KEY,reservation_id INTEGER REFERENCES reservations(id),channel TEXT NOT NULL CHECK(channel IN('email','whatsapp','sms')),event TEXT NOT NULL,
 recipient TEXT,status TEXT NOT NULL CHECK(status IN('sent','failed','skipped')),detail TEXT,created_at TEXT NOT NULL);
CREATE TABLE ai_conversations(id INTEGER PRIMARY KEY,token TEXT NOT NULL UNIQUE,status TEXT NOT NULL DEFAULT 'open' CHECK(status IN('open','handover','closed')),
 handover_reason TEXT,customer_name TEXT,customer_phone TEXT,created_at TEXT NOT NULL,updated_at TEXT NOT NULL);
CREATE TABLE ai_messages(id INTEGER PRIMARY KEY,conversation_id INTEGER NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
 role TEXT NOT NULL CHECK(role IN('user','assistant','tool')),content TEXT,tool_name TEXT,tool_calls TEXT,tool_call_id TEXT,created_at TEXT NOT NULL);
CREATE INDEX ix_msg_conv ON ai_messages(conversation_id);
CREATE TABLE audit_logs(id INTEGER PRIMARY KEY,at TEXT NOT NULL,user_id INTEGER,actor TEXT,action TEXT NOT NULL,entity TEXT,entity_id TEXT,detail TEXT);
CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT NOT NULL);
