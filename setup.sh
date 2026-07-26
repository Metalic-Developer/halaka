#!/bin/bash

echo "🔄 Starting Flutter project setup..."

# 1. تأكد إن Flutter في الـ PATH
export PATH="$PATH:$HOME/flutter/bin"

# 2. تحقق من البيئة
flutter --version
flutter doctor

# 3. جلب الـ dependencies
flutter pub get

# 4. تحديث الإصدارات لو فيه تعارضات
flutter pub upgrade --major-versions

# 5. توليد الملفات (Isar, Freezed, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# 6. تشغيل التطبيق مباشرة على الويب
echo "🚀 Launching app on web server..."
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
