#!/bin/sh

(
until fprintd-verify | grep "verify-match"; do
    echo "Failed to verify fingerprint at $(date)" | systemd-cat
    sleep 0.5
done
echo "Unlocked at $(date)" | systemd-cat
pkill -USR1 hyprlock
) &
hyprlock
kill $(jobs -p)
pkill fprintd-verify
