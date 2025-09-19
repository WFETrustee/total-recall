#!/bin/bash

echo "=== Total Recall Bootloader ==="
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKEND_DIR="$PROJECT_ROOT/backend"

# 1. Launch Flask backend if not already running
FLASK_PORT=5000
if ! lsof -i:$FLASK_PORT -sTCP:LISTEN -t >/dev/null ; then
  echo "Starting Flask backend on port $FLASK_PORT..."
  cd "$BACKEND_DIR" || exit 1
  nohup flask run --host=0.0.0.0 --port=$FLASK_PORT > "$PROJECT_ROOT/flask.log" 2>&1 &
  cd "$PROJECT_ROOT"
else
  echo "✅ Flask backend already running on port $FLASK_PORT"
fi

# 2. Prompt user for Flutter target
echo ""
echo "Which platform do you want to launch Flutter on?"
echo "1) Android"
echo "2) Web"
echo "3) iPhone (iOS Simulator)"
read -rp "Enter choice [1-3]: " platform_choice

# 3. Launch Flutter app
echo ""
case "$platform_choice" in
  1)
    echo "📱 Launching Flutter app on Android emulator..."
    AVD_NAME="android"
    EMULATOR_LOG="$PROJECT_ROOT/logs/emulator_$(date +%Y%m%d_%H%M%S).log"

    # Ensure logs folder exists
    mkdir -p "$PROJECT_ROOT/logs"

    # Check if emulator is already running
    if ! adb devices | grep -q "emulator-"; then
        echo "🔄 Starting Android emulator: $AVD_NAME"
        echo "📄 Logging emulator output to $EMULATOR_LOG"
        nohup ~/Library/Android/sdk/emulator/emulator -avd "$AVD_NAME" > "$EMULATOR_LOG" 2>&1 &
        
        echo "⏳ Waiting for emulator to boot..."
        sleep 10  # Initial delay to allow emulator startup

        # Wait for boot to complete
        until adb shell getprop sys.boot_completed | grep -m 1 "1" > /dev/null 2>&1; do
        echo "🕓 Still booting..."
        sleep 2
        done

        echo "✅ Android emulator booted successfully."
    else
        echo "✅ Android emulator already running."
    fi

    echo "📱 Launching Flutter app on Android emulator..."
    flutter run
    ;;
  2)
    echo "🌐 Launching Flutter app in Chrome browser..."
    flutter run -d chrome
    ;;
  3)
    echo "🍎 Launching Flutter app on iOS simulator..."
    flutter run -d ios
    ;;
  *)
    echo "❌ Invalid option. Exiting."
    exit 1
    ;;
esac
