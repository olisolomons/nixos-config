#!/usr/bin/env python3
import argparse
import shutil
import sys
import tarfile
import tempfile
from datetime import datetime
from pathlib import Path

HOME = Path.home()
SOURCE_DIR = HOME / ".thunderbird"
BACKUP_DIR = HOME / "Dropbox" / "ThunderbirdBackups"


def exclude_caches(tarinfo):
    """Exclude non-essential Thunderbird cache and temporary directories."""
    cache_dirs = {"Cache", "cache2", "startupCache", "OfflineCache", "crashes", "datareporting"}
    if any(part in cache_dirs for part in Path(tarinfo.name).parts):
        return None
    return tarinfo


def rotate_backups(backup_dir: Path, backup_type: str, max_keep: int) -> None:
    """Keep only the latest N backup archives for the specified backup type."""
    pattern = f"thunderbird_{backup_type}_*.tar.xz"
    backups = sorted(
        backup_dir.glob(pattern),
        key=lambda p: p.stat().st_mtime,
    )

    if len(backups) > max_keep:
        to_remove = backups[:-max_keep]
        for archive in to_remove:
            print(f"Removing old {backup_type} backup: {archive.name}")
            archive.unlink()


def create_backup(backup_type: str, max_keep: int) -> None:
    if not SOURCE_DIR.exists():
        print(f"Source directory {SOURCE_DIR} does not exist.")
        sys.exit(1)

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"thunderbird_{backup_type}_{timestamp}.tar.xz"
    final_path = BACKUP_DIR / filename

    # Create the archive inside a secure temporary directory
    print(f"Creating {backup_type} archive in local temp directory...")
    with tempfile.TemporaryDirectory() as tmp_dir:
        temp_archive_path = Path(tmp_dir) / filename

        with tarfile.open(temp_archive_path, "w:xz") as tar:
            tar.add(SOURCE_DIR, arcname=".thunderbird", filter=exclude_caches)

        print(f"Moving archive safely to Dropbox: {final_path}...")
        # shutil.move handles moving across filesystems/directories atomically
        shutil.move(str(temp_archive_path), str(final_path))

    print(f"{backup_type.capitalize()} backup completed successfully.")
    rotate_backups(BACKUP_DIR, backup_type, max_keep)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Thunderbird Profile Backup")
    parser.add_argument(
        "--type",
        choices=["daily", "monthly"],
        required=True,
        help="Type of backup to create",
    )
    parser.add_argument(
        "--keep",
        type=int,
        required=True,
        help="Number of backups of this type to retain",
    )
    args = parser.parse_args()

    create_backup(args.type, args.keep)
