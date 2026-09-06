#!/usr/bin/env python3
from pathlib import Path
import getpass
import subprocess
import json
import shutil
import sqlite3
import os

src = Path.home() / "Dropbox" / "Recipes"
kindle = Path("/") / "run" / "media" / getpass.getuser() / "Kindle"
kindle_dev = Path("/dev/disk/by-label/Kindle")


if not kindle.is_dir():
    if not kindle_dev.exists():
        print("Kindle is not plugged in!")
        exit(1)
    print("Mounting the kindle.")

    result = subprocess.run(
        ["udisksctl", "mount", "-b", str(kindle_dev)], capture_output=False, text=True, check=True
    )

index_path = kindle / "recipe_index.db"
with sqlite3.connect(index_path) as con:
    con.row_factory = sqlite3.Row

    cur = con.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS recipes (
      name TEXT PRIMARY KEY,
      version INTEGER,
      last_modified REAL,
      deleted INTEGER
    );
    """)

    def delete_recipe(doc_info):
        cur = con.cursor()
        cur.execute("UPDATE recipes SET deleted = TRUE WHERE name = ?", (doc_info['name'],))
        (kindle / "documents" / f"{doc_info['name']} v{doc_info['version']}.pdf").unlink(missing_ok=True)
        shutil.rmtree(kindle / "documents" / f"{doc_info['name']} v{doc_info['version']}.sdr", ignore_errors=True)
        con.commit()


    # PDFify recipes to kindle
    num_done = 0

    for doc in src.iterdir():
        if doc.suffix not in {".docx", ".odt", ".doc"}:
            continue

        cur = con.cursor()
        cur.execute("SELECT name,version,last_modified,deleted FROM recipes WHERE name = ?", (doc.stem,))
        doc_info = cur.fetchone() or {"name": doc.stem, "version": 0, "last_modified": 0, "deleted": False}

        if doc_info["last_modified"] >= doc.lstat().st_mtime and not doc_info["deleted"]:
            continue

        delete_recipe(doc_info)
        
        cur = con.cursor()
        cur.execute("""
            INSERT INTO recipes (name, version, last_modified, deleted) VALUES (?,?,?,?)
            ON CONFLICT(name) DO UPDATE SET
              version = excluded.version,
              last_modified = excluded.last_modified,
              deleted = excluded.deleted;
        """, (doc.stem, doc_info["version"] + 1, doc.lstat().st_mtime, False,))

        print(f"Converting to PDF: {doc.stem}")
        
        process = subprocess.run([
            "/usr/bin/env",
            "soffice",
            "--headless",
            f"-env:UserInstallation=file:///tmp/LibreOffice_Conversion_{getpass.getuser()}",
            "--convert-to", "pdf:writer_pdf_Export",
            "--outdir", "/tmp",
            doc
        ], capture_output=True)

        if process.returncode != 0:
            print(f"\nERROR converting {doc}\n")
            continue

        try:
            shutil.move(Path("/tmp") / f"{doc.stem}.pdf", kindle / "documents" / f"{doc.stem} v{doc_info['version'] + 1}.pdf")
        except OSError:
            print(f"Error moving the file {doc.stem} to kindle. Maybe it has a special character in it?")

        con.commit()

        num_done += 1
                
    # delete old recipes
    num_deleted = 0
    all_recipes = set(doc.stem for doc in src.iterdir())
    cur = con.cursor()
    cur.execute("SELECT name,version,last_modified,deleted FROM recipes WHERE deleted = FALSE")
    non_deleted_recipes = cur.fetchall()

    for doc_info in non_deleted_recipes:
        if doc_info["name"] not in all_recipes:
            delete_recipe(doc_info)
            num_deleted += 1

    # report
    match (num_done, num_deleted):
        case [0, 0]:
            print("All up to date!")
        case [0, _]:
            print(f"{num_deleted} recipes deleted!")
        case [_, 0]:
            print(f"{num_done} reciped updated!")
        case _:
            print(f"{num_deleted} deleted, {num_done} updated!")

con.close()
os.sync()

subprocess.run(["udisksctl", "unmount", "-b", str(kindle_dev)], check=True)
