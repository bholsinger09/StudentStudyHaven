#!/usr/bin/env ruby

require 'find'

puts "=" * 80
puts "SEARCHING FOR ALL STUDYGROUP VIEW FILES"
puts "=" * 80
puts

# Find all files containing StudyGroup in the name
study_group_files = []
Find.find('.') do |path|
  next if path.include?('.git') || path.include?('DerivedData') || path.include?('.build')
  if File.file?(path) && path.end_with?('.swift') && path.downcase.include?('studygroup')
    study_group_files << path
  end
end

study_group_files.sort.each do |file|
  puts file
  
  # Check if it contains GroupMembersView
  content = File.read(file)
  if content.include?('GroupMembersView')
    puts "  ➜ Contains GroupMembersView"
  end
  if content.include?('struct StudyGroupDetailView')
    puts "  ➜ Contains StudyGroupDetailView struct"
  end
  if content.include?('struct StudyGroupsView')
    puts "  ➜ Contains StudyGroupsView struct"
  end
end

puts
puts "=" * 80
puts "CHECKING FOR PACKAGE.SWIFT TARGET CONFIGURATION"
puts "=" * 80

if File.exist?('Package.swift')
  content = File.read('Package.swift')
  
  # Find StudyGroups target
  if content =~ /\.target\s*\(\s*name:\s*"StudyGroups".*?\)/m
    match = $&
    puts "StudyGroups target found:"
    puts match
  else
    puts "❌ StudyGroups target not found!"
  end
end

puts
puts "=" * 80
puts "CHECKING XCODE PROJECT REFERENCES"
puts "=" * 80

# Check if there's a pbxproj file
pbxproj_files = []
Find.find('.') do |path|
  if path.end_with?('project.pbxproj')
    pbxproj_files << path
  end
end

pbxproj_files.each do |pbxproj|
  puts "Found: #{pbxproj}"
  content = File.read(pbxproj)
  
  if content.include?('StudyGroupDetailView')
    puts "  ➜ References StudyGroupDetailView"
  end
  if content.include?('StudyGroups')
    puts "  ➜ References StudyGroups"
  end
end
