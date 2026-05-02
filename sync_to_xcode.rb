#!/usr/bin/env ruby

require 'fileutils'

# Files to sync from Sources/App/ to StudentStudyHaven/StudentStudyHaven/
FILES_TO_SYNC = [
  'AppState.swift',
  'DependencyContainer.swift',
  'HomeView.swift',
  'ProfileView.swift',
  'ProfileViewModel.swift',
  'RootView.swift',
  'StudentStudyHavenApp.swift'
]

SOURCE_DIR = 'Sources/App'
TARGET_DIR = 'StudentStudyHaven/StudentStudyHaven'

puts "=" * 80
puts "SYNCING FILES FROM #{SOURCE_DIR} TO #{TARGET_DIR}"
puts "=" * 80
puts

FILES_TO_SYNC.each do |filename|
  source_file = File.join(SOURCE_DIR, filename)
  target_file = File.join(TARGET_DIR, filename)
  
  if File.exist?(source_file)
    # Create backup of old file
    if File.exist?(target_file)
      backup_file = "#{target_file}.backup.#{Time.now.to_i}"
      FileUtils.cp(target_file, backup_file)
      puts "✓ Backed up: #{target_file} -> #{File.basename(backup_file)}"
    end
    
    # Copy new file
    FileUtils.cp(source_file, target_file)
    puts "✓ Copied: #{filename}"
  else
    puts "✗ Source file not found: #{source_file}"
  end
end

puts
puts "=" * 80
puts "SYNC COMPLETE"
puts "=" * 80
puts
puts "Next steps:"
puts "1. Open the project in Xcode"
puts "2. Clean Build Folder (Cmd+Shift+K)"
puts "3. Build and Run (Cmd+R)"
puts
puts "The Add Member button should now appear on the Members tab!"
