#!/bin/bash

# Configure Git identity (only needs to be done once per machine)
git config --global user.name "Gregory-Alan Williams"
git config --global user.email "trustee@williamsfamilyestate.org"

# Initialize repo
git init

# Ensure branch is 'main'
git checkout -b main 2>/dev/null || git checkout main

# Create .gitignore
cat > .gitignore <<'EOF'
# Flutter / Dart
.dart_tool/
.packages
.pub-cache/
build/
.flutter-plugins*
.flutter-plugins-dependencies
.melos_tool/
coverage/

# Android / Gradle
**/android/.gradle/
**/android/local.properties
**/android/**/generated/
**/android/**/gradle-wrapper.jar
**/android/**/captures/
**/android/**/build/

# iOS / macOS
**/ios/Pods/
**/ios/.symlinks/
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/macos/Flutter/ephemeral/
**/ios/Runner/GeneratedPluginRegistrant.*
**/macos/Runner/GeneratedPluginRegistrant.*

# VS Code
.vscode/
.history/

# System
.DS_Store
EOF

# Create starter README
echo "# TotalRecall" > README.md

# Stage and commit
git add .
git commit -m "Initial commit: project setup"

# Set remote
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/WFETrustee/TotalRecall.git

# Push to GitHub
git push -u origin main

