from flask import current_app
def razorpay_ready():c=current_app.config;return bool(c['RAZORPAY_KEY_ID'] and c['RAZORPAY_KEY_SECRET'])
