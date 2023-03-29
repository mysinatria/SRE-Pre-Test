#!/bin/bash

# Set the directory where the log files are located
# In this case I'm using /var/log/ACCESS-LOG directory
LOG_DIR="/var/log/ACCESS-LOG"

# Set the number of minutes to look back for errors
LOOKBACK_MINUTES=10

# Get the current time and the time that is 10 minutes ago
CURRENT_TIME=$(date +"%d/%b/%Y:%H:%M")
LOOKBACK_TIME=$(date -d "${LOOKBACK_MINUTES} minutes ago" +"%d/%b/%Y:%H:%M")

# Initialize the variable to keep track of the total number of errors
TOTAL_ERRORS=0

# Loop through all the log files in the directory
for LOG_FILE in ${LOG_DIR}/*.log; do
    # Use awk to find all the lines with a status code of 500 in the last 10 minutes
    NUM_ERRORS=$(awk -v current_time="$CURRENT_TIME" -v lookback_time="$LOOKBACK_TIME" '$0 > lookback_time && $0 < current_time && $9 == "500" {count++} END {print count}' ${LOG_FILE})

    # Add the number of errors for this log file to the total number of errors
    TOTAL_ERRORS=$((TOTAL_ERRORS + NUM_ERRORS))

    # Print the number of errors for this log file
    echo "There were ${TOTAL_ERRORS} HTTP 500 errors in ${LOG_FILE} in the last ${LOOKBACK_MINUTES} minutes."
done

# Print the total number of errors
echo "There were ${TOTAL_ERRORS} HTTP 500 errors in ${LOG_FILE} in the last ${LOOKBACK_MINUTES} minutes"
