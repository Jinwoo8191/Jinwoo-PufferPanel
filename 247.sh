#!/bin/bash

echo "How many minutes do you want to wait between pings to keep the session active?"
read -p "Enter a number (in minutes): " interval

# Convert minutes to seconds
seconds=$((interval * 60))

# Function to display an animated message with colors
function show_animated_message {
  local message="Sending pings every $interval minute(s). Press Ctrl+C to stop."
  local colors=(31 32 33 34 35 36) # Red, green, yellow, blue, magenta, cyan
  while true; do
    for color in "${colors[@]}"; do
      echo -ne "\e[1;${color}m$message\e[0m\r"
      sleep 0.3
    done
  done
}

# Run the animated message in the background
show_animated_message &

# Save the PID of the animated process to stop it later
animation_pid=$!

# Keep the session active
echo "Keeping the session active..."
while true; do
  curl -s https://gitpod.io/ping > /dev/null
  sleep "$seconds"  # Wait for the specified interval
done

# Stop the animation (this only runs if the script ends, which typically doesn’t happen)
kill $animation_pid
