#!/bin/bash

echo "🚀 Quick run script..."

# تأكد إن Flutter في الـ PATH
export PATH="$PATH:$HOME/flutter/bin"

# تشغيل التطبيق مباشرة على الويب
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
