# API (JSON). Writes need the `X-CSRF-Token` header (value from `<meta name="csrf">`) and the same session cookie.
| Method | Path | Purpose |
|---|---|---|
| GET | /api/health | liveness + database check |
| GET | /api/availability?check_in&check_out&adults&children&category_id&property_id | available rooms with price, tax, total (paise) |
| GET | /api/price-calendar?category_id&start&months | nightly `price_paise`, `peak`, and `notify_me` per date; months 1–12 |
| GET | /api/price-quote?category_id&check_in&check_out | nightly dynamic-price breakdown and stay total (paise) |
| GET | /api/media?kind&property_id&category_id | active slide, gallery, or room-category media ordered by sort |
| POST | /api/bookings | `{room_id,check_in,check_out,adults,children,name,phone,email,notes}` → 201 `{reference}`; 409 if unavailable; 400 with `fields` |
| POST | /api/payments/order | `{reference}` → Razorpay order (only for your own pending booking) |
| POST | /api/payments/verify | Razorpay checkout response; server verifies signature |
| POST | /api/payments/failed | `{order_id,reason}` |
| POST | /api/payments/webhook | Razorpay webhook (signature verified, CSRF-exempt) |
| POST | /api/chat | `{message}` → `{reply,status,booking}` (conversation kept in the session) |
Staff functions use the signed-in admin pages (role-checked, CSRF-protected). Rate limits: bookings 10 per 10 min, chat 25 per minute, and read-only public pricing/media endpoints 60 per minute, per IP.
