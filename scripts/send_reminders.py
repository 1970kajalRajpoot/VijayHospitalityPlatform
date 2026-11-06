"""Run daily from cron: sends check-in reminders for tomorrow's confirmed bookings."""
import sys,os;sys.path.insert(0,os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import create_app
from app.db import get_db
from app.services import notify
app=create_app()
with app.app_context():print(notify.send_reminders(get_db()),'reminders attempted')
