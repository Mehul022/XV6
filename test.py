import matplotlib.pyplot as plt
import re

# Data Parsing Function
def parse_log(log_lines):
    process_run_intervals = []
    current_running_process = None
    last_time = None

    for line in log_lines:
        # Extract time for each log entry (e.g., "time =365")
        time_match = re.search(r'time =(\d+)', line)
        if time_match:
            current_time = int(time_match.group(1))

        # Handle initial priority assignment (e.g., "Process 6 has priority 0")
        match_init = re.search(r'Process (\d+) has priority (\d+)', line)
        if match_init:
            pid = int(match_init.group(1))
            priority = int(match_init.group(2))

            # Store the current process data
            if current_running_process is None:
                current_running_process = {"pid": pid, "priority": priority}
                last_time = current_time
            else:
                # End the previous process and store its interval
                process_run_intervals.append({
                    "pid": current_running_process["pid"],
                    "start_time": last_time,
                    "end_time": current_time,
                    "priority": current_running_process["priority"]
                })
                # Start the new running process
                current_running_process = {"pid": pid, "priority": priority}
                last_time = current_time

    # End the last running process and store its interval
    if current_running_process is not None and last_time is not None:
        process_run_intervals.append({
            "pid": current_running_process["pid"],
            "start_time": last_time,
            "end_time": current_time,
            "priority": current_running_process["priority"]
        })

    return process_run_intervals

# Read log data from log.txt
with open("log.txt", "r") as file:
    log_lines = file.readlines()

# Parse the log data
process_run_intervals = parse_log(log_lines)

# Define the hardcoded PIDs to plot
hardcoded_pids = {4, 5, 6, 7}

# Assign colors for hardcoded PIDs
process_colors = {
    4: 'blue',
    5: 'purple',
    6: 'orange',
    7: 'cyan'
}

# Create a list for the legend with hardcoded PIDs and their colors
legend_entries = [
    {"pid": 4, "color": 'blue'},
    {"pid": 5, "color": 'purple'},
    {"pid": 6, "color": 'orange'},
    {"pid": 7, "color": 'cyan'}
]

# Plot the results
plt.figure(figsize=(12, 8))

# Plot each process' running intervals for hardcoded PIDs only
for interval in process_run_intervals:
    pid = interval["pid"]
    
    # Only process hardcoded PIDs
    if pid not in hardcoded_pids:
        continue

    time_start = interval["start_time"]
    time_end = interval["end_time"]
    priority = interval["priority"]

    # Assign color based on PID
    color = process_colors.get(pid)

    # Plot horizontal line when process is running (priority + 0.5)
    plt.plot([time_start, time_end], [priority + 0.5, priority + 0.5], color=color)

    # Draw vertical lines at start and end of the running period
    plt.plot([time_start, time_start], [priority, priority + 0.5], color=color)
    plt.plot([time_end, time_end], [priority + 0.5, priority], color=color)

# Customize the plot
plt.xlabel("Time")
plt.ylabel("Priority Level")
plt.title("Process Running Intervals")
plt.gca().invert_yaxis()  # Priority decreases go down
plt.grid(True)

# Create a legend using the new legend_entries array
for entry in legend_entries:
    plt.plot([], [], color=entry["color"], label=f"Process {entry['pid']}")

plt.legend(loc="upper right")

# Show the plot
plt.show()
