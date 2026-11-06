"""Import photos/slides, photos/gallery, and photos/rooms/<category-name> once.

Exactly four landscape images are required in photos/slides. Room subdirectory names
must match a room category name (case-insensitive).
"""
import io
import os
import sys
from PIL import Image
from werkzeug.datastructures import FileStorage

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import create_app
from app.db import get_db
from app.services import media as M

PHOTO_ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'photos')
EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp'}


def files_below(folder):
    if not os.path.isdir(folder):
        return []
    out = []
    for root, dirs, names in os.walk(folder):
        dirs.sort()
        for name in sorted(names):
            if os.path.splitext(name)[1].lower() in EXTENSIONS:
                out.append(os.path.join(root, name))
    return out


def seed():
    if not os.path.isdir(PHOTO_ROOT):
        raise SystemExit('Create photos/slides, photos/gallery, and photos/rooms/<category> first.')
    slides = files_below(os.path.join(PHOTO_ROOT, 'slides'))
    gallery = files_below(os.path.join(PHOTO_ROOT, 'gallery'))
    room_root = os.path.join(PHOTO_ROOT, 'rooms')
    room_files = files_below(room_root)
    if len(slides) != 4:
        raise SystemExit('photos/slides must contain exactly four landscape images.')
    for path in slides:
        with Image.open(path) as image:
            if image.width <= image.height:
                raise SystemExit(f'Slide must be landscape: {os.path.relpath(path, PHOTO_ROOT)}')
    app = create_app()
    with app.app_context():
        db = get_db()
        categories = {r['name'].casefold(): dict(r) for r in db.execute('SELECT id,name,property_id FROM room_categories')}
        jobs = [('slide', None, None, x) for x in slides]
        jobs += [('gallery', None, None, x) for x in gallery]
        for path in room_files:
            category_name = os.path.basename(os.path.dirname(path)).casefold()
            category = categories.get(category_name)
            if not category:
                raise SystemExit(f'Unknown room category directory: {os.path.dirname(path)}')
            jobs.append(('room', category['property_id'], category['id'], path))
        inserted = skipped = 0
        for kind, property_id, category_id, source in jobs:
            relative = os.path.relpath(source, PHOTO_ROOT).replace('\\', '/')
            source_key = kind + ':' + relative.casefold()
            if db.execute('SELECT 1 FROM site_media WHERE source_key=?', (source_key,)).fetchone():
                skipped += 1
                continue
            with open(source, 'rb') as image_file:
                raw = image_file.read(M.MAX_UPLOAD_BYTES + 1)
            upload = FileStorage(stream=io.BytesIO(raw), filename=os.path.basename(source))
            stored = M.save_upload(upload, app.config['UPLOAD_DIR'])
            title = os.path.splitext(os.path.basename(source))[0][:120]
            saved = False
            try:
                db.execute(
                    'INSERT INTO site_media(kind,property_id,category_id,title,path,sort,source_key) VALUES(?,?,?,?,?,?,?)',
                    (kind, property_id, category_id, title, stored['path'],
                     db.execute('SELECT COALESCE(MAX(sort),-1)+1 FROM site_media WHERE kind=?', (kind,)).fetchone()[0],
                     source_key),
                )
                saved = True
            finally:
                if not saved:
                    M.delete_upload(stored['path'], app.config['UPLOAD_DIR'])
            inserted += 1
        print(f'Imported {inserted} media items; skipped {skipped} already imported.')


if __name__ == '__main__':
    seed()
