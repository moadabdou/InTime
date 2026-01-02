#!/bin/bash
#
# Test script for InTime Widget
# Runs the widget for 5 seconds to verify it works
#

echo "Testing InTime Widget..."
echo "The clock should appear on your screen for 5 seconds."
echo ""

cd "$(dirname "$0")/src"

# Run widget for 5 seconds
timeout 5 ./intime_widget.py

echo ""
echo "Test complete!"
echo "If you saw a transparent clock overlay, the widget is working correctly."
