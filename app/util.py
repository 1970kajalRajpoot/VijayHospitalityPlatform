import re,datetime as dt
from zoneinfo import ZoneInfo
TZ=ZoneInfo('Asia/Kolkata')
def now():return dt.datetime.now(TZ).replace(microsecond=0)
def now_s():return now().strftime('%Y-%m-%d %H:%M:%S')
def today():return now().date()
def d(s):return dt.date.fromisoformat(s)
def daterange(a,b):
    x=d(a);y=d(b)
    while x<y:yield x.isoformat();x+=dt.timedelta(days=1)
def inr(p):
    r=p/100;return '₹{:,.0f}'.format(r) if abs(r-round(r))<.005 else '₹{:,.2f}'.format(r)
PH=re.compile(r'^[6-9]\d{9}$');EM=re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
def norm_phone(p):
    s=re.sub(r'\D','',p or '')
    if len(s)==12 and s.startswith('91'):s=s[2:]
    elif len(s)==11 and s.startswith('0'):s=s[1:]
    return s if PH.match(s) else None
