#!/usr/bin/env python3
import argparse
import sys
import tarfile
from datetime import datetime
from pathlib import Path

HOME = Path.home()
SOURCE_DIR = HOME / ".thunderbird"
BACKUP_DIR = HOME / "Dropbox" / "ThunderbirdBackups"


def rotate_backups(backup_dir: Path, backup_type: str, max_keep: int) -> None:
    """Keep only the latest N backup archives for the specified backup type."""
    pattern = f"thunderbird_{backup_type}_*.tar.gz"
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
    archive_path = BACKUP_DIR / f"thunderbird_{backup_type}_{timestamp}.tar.gz"

    print(f"Creating {backup_type} archive at {archive_path}...")
    with tarfile.open(archive_path, "w:gz") as tar:
        tar.add(SOURCE_DIR, arcname=".thunderbird")

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
