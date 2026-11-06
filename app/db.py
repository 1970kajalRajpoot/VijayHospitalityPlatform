import sqlite3,os,contextlib,glob
from flask import g,current_app
def connect(path):
    if path!=':memory:':os.makedirs(os.path.dirname(os.path.abspath(path)),exist_ok=True)
    c=sqlite3.connect(path,timeout=20,isolation_level=None);c.row_factory=sqlite3.Row
    c.execute('PRAGMA foreign_keys=ON');c.execute('PRAGMA journal_mode=WAL');c.execute('PRAGMA busy_timeout=20000');return c
def get_db():
    if 'db' not in g:g.db=connect(current_app.config['DATABASE'])
    return g.db
def close_db(e=None):
    db=g.pop('db',None)
    if db is not None:db.close()
@contextlib.contextmanager
def tx(db):
    """BEGIN IMMEDIATE takes the write lock first, so concurrent bookings are serialised."""
    db.execute('BEGIN IMMEDIATE')
    try:yield db;db.execute('COMMIT')
    except BaseException:
        db.execute('ROLLBACK');raise
def migrate(path,folder=None):
    folder=folder or os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),'migrations');db=connect(path)
    db.execute('CREATE TABLE IF NOT EXISTS schema_migrations(name TEXT PRIMARY KEY,applied_at TEXT DEFAULT CURRENT_TIMESTAMP)')
    done={r[0] for r in db.execute('SELECT name FROM schema_migrations')};ran=[]
    for f in sorted(glob.glob(os.path.join(folder,'*.sql'))):
        n=os.path.basename(f)
        if n in done:continue
        with open(f,encoding='utf-8') as fh:sql=fh.read().rstrip().rstrip(';')
        try:db.executescript('BEGIN;'+sql+";INSERT INTO schema_migrations(name) VALUES('"+n.replace("'","")+"');COMMIT;")
        except BaseException:
            if db.in_transaction:db.execute('ROLLBACK')
            raise
        ran.append(n)
    db.close();return ran
def setting(db,key,default=None):
    r=db.execute('SELECT value FROM settings WHERE key=?',(key,)).fetchone();return r[0] if r else default
def set_setting(db,key,value):
    db.execute('INSERT INTO settings(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value',(key,str(value)))
