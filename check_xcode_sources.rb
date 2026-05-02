#!/usr/bin/env ruby

require 'find'

# Find all Swift files in Sources/ directory
sources_files = []
Find.find('Sources') do |path|
  if path.end_with?('.swift') && !path.include?('.disabled')
    sources_files << path
  end
end

# Find all Swift files in StudentStudyHaven/ directory
xcode_files = []
if Dir.exist?('StudentStudyHaven')
  Find.find('StudentStudyHaven') do |path|
    if path.end_with?('.swift')
      xcode_files << path
    end
  end
end

puts "=" * 80
puts "SWIFT FILES IN SOURCES/ (Swift Package Manager)"
puts "=" * 80
sources_files.sort.each { |f| puts f }

puts "\n"
puts "=" * 80
puts "SWIFT FILES IN StudentStudyHaven/ (Xcode App Target)"
puts "=" * 80
xcode_files.sort.each { |f| puts f }

# Check for potential duplicates
puts "\n"
puts "=" * 80
puts "CHECKING FOR DUPLICATE FILENAMES"
puts "=" * 80

sources_basenames = sources_files.map { |f| File.basename(f) }
xcode_basenames = xcode_files.map { |f| File.basename(f) }

duplicates = sources_basenames & xcode_basenames
if duplicates.any?
  puts "⚠️  WARNING: Found #{duplicates.length} files with same names in both locations:"
  duplicates.each do |basename|
    source_path = sources_files.find { |f| File.basename(f) == basename }
    xcode_path = xcode_files.find { |f| File.basename(f) == basename }
    puts "  - #{basename}"
    puts "    Sources:  #{source_path}"
    puts "    Xcode:    #{xcode_path}"
  end
else
  puts "✓ No duplicate filenames found"
end

# Check if StudyGroupDetailView exists in both
puts "\n"
puts "=" * 80
puts "CHECKING StudyGroupDetailView.swift LOCATION"
puts "=" * 80

study_group_detail_sources = sources_files.select { |f| f.include?('StudyGroupDetailView') }
study_group_detail_xcode = xcode_files.select { |f| f.include?('StudyGroupDetailView') }

puts "In Sources/: #{study_group_detail_sources.any? ? study_group_detail_sources.join(', ') : 'NOT FOUND'}"
puts "In Xcode/:   #{study_group_detail_xcode.any? ? study_group_detail_xcode.join(', ') : 'NOT FOUND'}"

if study_group_detail_xcode.any?
  puts "\n⚠️  PROBLEM: StudyGroupDetailView exists in Xcode app directory!"
  puts "This file is likely shadowing the one in Sources/"
end
