#!/usr/bin/env ruby

puts "=" * 80
puts "NUCLEAR CLEAN & REBUILD SCRIPT"
puts "=" * 80
puts

# Step 1: Clean all build artifacts
puts "1. Removing all build artifacts..."
system("rm -rf .build")
system("rm -rf ~/Library/Developer/Xcode/DerivedData/StudentStudyHaven-*")
system("rm -rf StudentStudyHaven.xcodeproj/.build")
puts "   ✅ Removed build caches"

# Step 2: Build package fresh
puts "\n2. Building Swift Package fresh..."
result = system("swift build")
if result
  puts "   ✅ Package build successful"
else
  puts "   ❌ Package build failed!"
  exit 1
end

# Step 3: Verify our changes are in the compiled code
puts "\n3. Verifying DEBUG INFO is in the source..."
detail_view = File.read('Sources/StudyGroups/Presentation/Views/StudyGroupDetailView.swift')
if detail_view.include?('DEBUG INFO') && detail_view.include?('👥 GroupMembersView INIT')
  puts "   ✅ Debug code is present in source"
else
  puts "   ❌ Debug code is MISSING! This shouldn't happen!"
  exit 1
end

puts "\n" + "=" * 80
puts "REBUILD COMPLETE"
puts "=" * 80
puts
puts "NOW IN XCODE:"
puts "1. Make sure Xcode is open with StudentStudyHaven.xcworkspace"
puts "2. Press Cmd+Shift+K (Product → Clean Build Folder)"
puts "3. Press Cmd+B (Product → Build)"
puts "4. Press Cmd+R (Product → Run)"
puts
puts "EXPECTED CONSOLE OUTPUT when you navigate to Members tab:"
puts "  🔍 StudyGroupDetailView INIT"
puts "  👥 GroupMembersView INIT"
puts "  📱 NavigationLink for: [group name]"
puts
puts "EXPECTED UI:"
puts "  - Members list"
puts "  - DEBUG INFO section (with use case status)"
puts "  - Manage Members section"
puts "  - Add Member button"
puts
puts "If logs don't appear, there's a project configuration issue."
puts "If logs appear but button doesn't show, screenshot the DEBUG INFO section."
puts
