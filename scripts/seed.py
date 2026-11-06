"""Create the two properties, the AC / Non-AC categories and standard amenities. No rooms, bookings or prices are invented.
Rates are 0 until set in Admin > Categories and rates, so nothing is bookable until you price it."""
import sys,os;sys.path.insert(0,os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import create_app
from app.db import get_db
app=create_app()
with app.app_context():
    db=get_db()
    P=[('vijay-utsav','Vijay Utsav','Hotel','Vijay Utsav Hall, South of Sikhar More, Post Baragandhar, Manpur, Gaya, Bihar, India','Hotel in Manpur, Gaya with AC and Non-AC rooms.'),
       ('vijay-garden','Vijay Garden','Hotel, banquet and events','Vijay Garden, South of Sikhar More, Manpur, Gaya, Bihar, India','Hotel rooms and a landscaped banquet lawn with a stage.')]
    for s,n,k,a,d in P:db.execute('INSERT OR IGNORE INTO properties(slug,name,kind,address,description) VALUES(?,?,?,?,?)',(s,n,k,a,d))
    for p in db.execute('SELECT id,slug FROM properties').fetchall():
        db.execute("INSERT OR IGNORE INTO room_categories(property_id,name,ac,description,base_price_paise,max_adults,max_children,image) VALUES(?,?,1,?,0,2,1,?)",(p['id'],'AC Room','Air-conditioned room with a double bed, private bathroom and housekeeping.','room-ac' if p['slug']=='vijay-utsav' else None))
        db.execute("INSERT OR IGNORE INTO room_categories(property_id,name,ac,description,base_price_paise,max_adults,max_children) VALUES(?,?,0,?,0,2,1)",(p['id'],'Non-AC Room','Budget-friendly fan-cooled room with a private bathroom and housekeeping.'))
    for a in ['Private bathroom','Housekeeping','Reception','24-hour security','Telephone service','Electronic safe','Balcony']:db.execute('INSERT OR IGNORE INTO amenities(name) VALUES(?)',(a,))
    print('Seeded properties and categories. Verify addresses in Admin > Settings and set room rates before taking bookings.')
