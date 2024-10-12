import matplotlib.pyplot as plt
import re

# Data Parsing Function
def parse_log(log_lines):
    process_data = {}
    time_step = 0
    for line in log_lines:
        # Handle initial priority assignment (e.g., "Process 6 has priority 0")
        match_init = re.search(r'Process (\d+) has priority (\d+)', line)
        if match_init:
            pid = int(match_init.group(1))
            priority = int(match_init.group(2))
            if pid not in process_data:
                process_data[pid] = {"time": [], "priority": []}
            process_data[pid]["time"].append(time_step)
            process_data[pid]["priority"].append(priority)
            time_step += 1

        # Handle priority decreases
        match_decrease = re.search(r'Process with pid (\d+) priority id decreased to (\d+)', line)
        if match_decrease:
            pid = int(match_decrease.group(1))
            priority = int(match_decrease.group(2))
            if pid not in process_data:
                process_data[pid] = {"time": [], "priority": []}
            process_data[pid]["time"].append(time_step)
            process_data[pid]["priority"].append(priority)
            time_step += 1

        # Handle priority boosts
        match_boost = re.search(r'Priority boost to process id (\d+) from priority \d+ to (\d+)', line)
        if match_boost:
            pid = int(match_boost.group(1))
            priority = int(match_boost.group(2))
            if pid not in process_data:
                process_data[pid] = {"time": [], "priority": []}
            process_data[pid]["time"].append(time_step)
            process_data[pid]["priority"].append(priority)
            time_step += 1

    return process_data

# Read log data from log.txt
with open("log.txt", "r") as file:
    log_lines = file.readlines()

# Parse the log data
process_data = parse_log(log_lines)

# Define special PIDs to assign specific colors
special_pids = {4, 5, 6, 7}

# Assign colors for special PIDs and black for others
process_colors = {
    4: 'blue',
    5: 'purple',
    6: 'orange',
    7: 'cyan'
}

# Plot the results
plt.figure(figsize=(10, 6))

# Plot each process' priority over time
for pid, data in process_data.items():
    times = data["time"]
    priorities = data["priority"]

    # Assign color based on PID, defaulting to black for non-special PIDs
    color = process_colors.get(pid, 'black')

    # Plot the initial point for each process
    plt.plot(times[0], priorities[0], marker='o', color=color, label=f"Process {pid}" if pid in special_pids else "Other")

    for i in range(1, len(times)):
        x_vals = [times[i-1], times[i]]
        y_vals = [priorities[i-1], priorities[i]]

        # Draw the vertical line with the process's color
        plt.plot([times[i], times[i]], [priorities[i-1], priorities[i]], color=color, lw=2)

        # Plot the horizontal line in the process's color
        plt.plot(x_vals, [priorities[i-1], priorities[i-1]], color=color, lw=2)

# Customize the plot
plt.xlabel("Time Step (Event Occurrence)")
plt.ylabel("Priority Level")
plt.title("Process Priority Changes Over Time")
plt.gca().invert_yaxis()  # Priority decreases go down
plt.grid(True)

# Set legend to show only special processes
plt.legend()

# Show the plot
plt.show()
