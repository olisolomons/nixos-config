import subprocess
import re
import sys

def main():
    # Define your desired target resolution for the laptop screen here:
    TARGET_W = 1920
    TARGET_H = 1200
    TARGET_LAPTOP_MODE = f"{TARGET_W}x{TARGET_H}@59.950"

    try:
        result = subprocess.run(["gdctl", "show"], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running gdctl show: {e.stderr}", file=sys.stderr)
        sys.exit(1)

    # Parse gdctl show output by tracking blocks per monitor connector
    monitors_data = {}
    current_connector = None
    current_width = None
    current_height = None
    current_mode_str = None
    all_monitor_modes = {} # Store modes per connector if multiple are listed

    for line in result.stdout.splitlines():
        # Match connector lines
        conn_match = re.search(r"\b(?:eDP|DP|HDMI|USB-C)[-\w]+\b", line)
        if conn_match and "Monitor" in line:
            if current_connector and current_width and current_height:
                monitors_data[current_connector] = {
                    "width": current_width,
                    "height": current_height,
                    "mode": current_mode_str
                }
            current_connector = conn_match.group(0)
            current_width = None
            current_height = None
            current_mode_str = None
            if current_connector not in all_monitor_modes:
                all_monitor_modes[current_connector] = []

        # Match mode lines like "2560x1440@59.951" or "1920x1200@59.950"
        mode_match = re.search(r"\b(\d+)x(\d+)@([\d.]+)\b", line)
        if mode_match and current_connector:
            w, h = int(mode_match.group(1)), int(mode_match.group(2))
            mode_str = mode_match.group(0)
            all_monitor_modes[current_connector].append((w, h, mode_str))
            
            # Keep track of the active/current one as primary default
            if "Current mode" in result.stdout or current_width is None:
                current_width = w
                current_height = h
                current_mode_str = mode_str

    # Save the last parsed monitor block
    if current_connector and current_width and current_height:
        monitors_data[current_connector] = {
            "width": current_width,
            "height": current_height,
            "mode": current_mode_str
        }

    if not monitors_data:
        print("Error: Could not parse any monitor dimensions from gdctl show.", file=sys.stderr)
        sys.exit(1)

    laptop_mon = None
    external_mons = []

    for conn in monitors_data.keys():
        if conn.startswith("eDP") or conn.startswith("LVDS"):
            laptop_mon = conn
        else:
            external_mons.append(conn)

    if not laptop_mon:
        print("Error: Could not identify internal laptop monitor (eDP).", file=sys.stderr)
        sys.exit(1)

    # Base command: 'gdctl set' with '--persistent'
    cmd = ["gdctl", "set", "--persistent"]

    if not external_mons:
        print("No external monitors attached. Resetting laptop screen...")
        cmd.extend([
            "--logical-monitor", "--primary",
            "--monitor", laptop_mon,
            "--scale", "1",
            "--mode", TARGET_LAPTOP_MODE,
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

    total_ext_width = monitors_data[external_mons[0]]["width"]
    max_ext_height = monitors_data[external_mons[0]]["height"]

    # Chain additional external monitors to the right of the previous one
    prev_ext = external_mons[0]
    for ext in external_mons[1:]:
        cmd.extend([
            "--logical-monitor",
            "--monitor", ext,
            "--scale", "1",
            "--right-of", prev_ext
        ])
        ext_data = monitors_data[ext]
        total_ext_width += ext_data["width"]
        if ext_data["height"] > max_ext_height:
            max_ext_height = ext_data["height"]
        prev_ext = ext

    # Calculate laptop positioning using the target width
    laptop_x = max(0, (total_ext_width - TARGET_W) // 2)
    laptop_y = max_ext_height

    cmd.extend([
        "--logical-monitor",
        "--monitor", laptop_mon,
        "--scale", "1",
        "--mode", TARGET_LAPTOP_MODE,
        "--x", str(laptop_x),
        "--y", str(laptop_y)
    ])

    print(f"Applying layout via gdctl (External width: {total_ext_width}px, Laptop centered at x={laptop_x}, y={laptop_y} with mode {TARGET_LAPTOP_MODE})...")
    try:
        subprocess.run(cmd, check=True)
        print("Layout applied and saved persistently successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Error applying layout with gdctl: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
