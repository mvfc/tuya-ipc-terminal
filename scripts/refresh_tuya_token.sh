#!/bin/sh

CONTAINER_NAME="${CONTAINER_NAME}"
REGION="${REGION}"
EMAIL="${EMAIL}"
PASSWORD="${PASSWORD}"
BINARY_PATH="/app/tuya-ipc-terminal"

# Execute the refresh command non-interactively inside the running container
echo "$PASSWORD" | docker exec -i "$CONTAINER_NAME" \
    /usr/bin/expect -c "
    set timeout 30
    # Spawn the tuya command
    spawn $BINARY_PATH auth refresh $REGION $EMAIL --password
    
    # Wait for the password prompt
    expect \"Enter password:\"
    
    # Send the password followed by a carriage return (\r)
    send \"$PASSWORD\r\"
    
    # Wait for the process to complete
    expect eof

    # Wait for the spawned process to exit and capture its status
    catch wait result
    
    # Return the exit code of the spawned process (index 3 of the 'wait' result)
    exit [lindex \$result 3]
"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date)] SUCCESS: Token refresh completed."
else
    echo "[$(date)] ERROR: Token refresh failed with exit code $EXIT_CODE."
    # Add logging or notification logic here if the refresh fails
fi
