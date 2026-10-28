#!/usr/bin/env python3
import subprocess
import re
import sys

def main():
    try:
        result = subprocess.run(["gdctl", "show"], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running gdctl show: {e.stderr}", file=sys.stderr)
        sys.exit(1)

    # Parse gdctl show blocks to extract logical monitors, their connectors, and x coordinates
    logical_monitors = []
    current_x = 0
    current_connectors = []

    for line in result.stdout.splitlines():
        # A new logical monitor block usually starts or contains position info
        x_match = re.search(r"x:\s*(-?\d+)", line)
        if x_match:
            if current_connectors:
                logical_monitors.append({"x": current_x, "connectors": current_connectors})
                current_connectors = []
            current_x = int(x_match.group(1))

        # Capture connector names inside the block
        conn_match = re.search(r"\b(?:eDP|DP|HDMI|USB-C)[-\w]+\b", line)
        if conn_match:
            conn = conn_match.group(0)
            if conn not in current_connectors:
                # Avoid capturing duplicate header labels if any
                current_connectors.append(conn)

    # Catch the last block if any
    if current_connectors:
        logical_monitors.append({"x": current_x, "connectors": current_connectors})

    # Fallback parser if gdctl formatting varies or returns minimal text:
    if not logical_monitors:
        found_connectors = list(set(re.findall(r"\b(?:eDP|DP|HDMI|USB-C)[-\w]+\b", result.stdout)))
        logical_monitors = [{"x": 0, "connectors": [c]} for c in found_connectors]

    laptop_mon = None
    external_mons = []

    # Flatten and segregate while preserving order
    seen = set()
    for group in sorted(logical_monitors, key=lambda g: g["x"]):
        for conn in group["connectors"]:
            if conn in seen:
                continue
            seen.add(conn)
            if conn.startswith("eDP") or conn.startswith("LVDS"):
                laptop_mon = conn
            else:
                external_mons.append(conn)

    if not laptop_mon:
        print("Error: Could not identify internal laptop monitor (eDP).", file=sys.stderr)
        sys.exit(1)

    # Base command: 'gdctl set' with '--persistent' (-P)
    cmd = ["gdctl", "set", "--persistent"]

    if not external_mons:
        print("No external monitors attached. Resetting laptop screen...")
        cmd.extend([
            "--logical-monitor", "--primary",
            "--monitor", laptop_mon,
            "--scale", "2.5",
            "--x", "0", "--y", "0"
        ])
        subprocess.run(cmd, check=True)
        print("Laptop layout applied and saved!")
        return

    # Configure the first external monitor as primary at 0, 0
    cmd.extend([
        "--logical-monitor", "--primary",
        "--monitor", external_mons[0],
        "--scale", "1",
        "--x", "0", "--y", "0"
    ])

    # Chain additional external monitors to the right of the previous one
    prev_ext = external_mons[0]
    for ext in external_mons[1:]:
        cmd.extend([
            "--logical-monitor",
            "--monitor", ext,
            "--scale", "1",
            "--right-of", prev_ext
        ])
        prev_ext = ext

    # Place laptop underneath the first external monitor
    cmd.extend([
        "--logical-monitor",
        "--monitor", laptop_mon,
        "--scale", "2.5",
        "--below", external_mons[0]
    ])

    print(f"Applying and persisting layout via gdctl (External order: {external_mons}, Laptop: {laptop_mon})...")
    try:
        subprocess.run(cmd, check=True)
        print("Layout applied and saved persistently successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Error applying layout with gdctl: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
