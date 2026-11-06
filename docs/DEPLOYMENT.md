# Deployment and operations
GoDaddy shared cPanel hosting usually cannot run a Flask app reliably; use a VPS (Ubuntu) or a Python-capable host.
1. Install Python 3.10+, nginx, certbot. Copy the project to `/srv/vijay`, create a venv, `pip install -r requirements.txt`.
2. `.env` with `APP_ENV=production`, strong `SECRET_KEY`, `SITE_URL=https://yourdomain`, `TRUSTED_PROXY=1`.
3. Run `python scripts/seed.py` and `python scripts/create_admin.py`.
4. systemd service: `ExecStart=/srv/vijay/.venv/bin/gunicorn -w 2 -b 127.0.0.1:8000 wsgi:app`, `WorkingDirectory=/srv/vijay`, `User=www-data`.
5. nginx: proxy to 127.0.0.1:8000, `client_max_body_size 6m`, HTTPS via certbot, redirect http to https. Serve `/static/` directly if you like.
6. Restrict `/admin` by IP or add HTTP basic auth at nginx if possible.
7. Check `https://yourdomain/api/health`, submit `https://yourdomain/sitemap.xml` to Google Search Console.
## Backup and recovery
SQLite online backup (safe while running), daily cron: `sqlite3 instance/hotel.db ".backup '/backups/hotel-$(date +%F).db'"`; also copy `app/static/uploads/`. Keep 30 days off-server.
Restore: stop the service, replace `instance/hotel.db` with the backup (delete `-wal`/`-shm` files), start the service, open `/api/health`.
## Logs and monitoring
`instance/app.log` (rotating, no secrets or card data). Review Admin > Audit log. Monitor `/api/health` with an uptime service.
