#!/usr/bin/env ruby
# Registers Swift source files into the Namtsetsoba Xcode project (objectVersion 56,
# no file-system-synchronized groups). Creates the group hierarchy mirroring each
# file's path relative to the source root, adds a file reference, and adds the file
# to the app target's Sources build phase. Idempotent.
#
# Usage: ruby tools/sync_project.rb <abs_swift_file> [<abs_swift_file> ...]

require 'xcodeproj'
require 'pathname'

PROJECT_PATH = File.expand_path('../Namtsetsoba/Namtsetsoba.xcodeproj', __dir__)
TARGET_NAME  = 'Namtsetsoba'
SOURCE_ROOT  = File.expand_path('../Namtsetsoba/Namtsetsoba', __dir__)

project = Xcodeproj::Project.open(PROJECT_PATH)
target  = project.targets.find { |t| t.name == TARGET_NAME }
abort("Target #{TARGET_NAME} not found") unless target

existing_paths = project.files.map { |f| f.real_path.to_s }
main_group = project.main_group.find_subpath('Namtsetsoba', true)

def group_for(project, root_group, source_root, file_path)
  rel = Pathname.new(File.dirname(file_path)).relative_path_from(Pathname.new(source_root)).to_s
  return root_group if rel == '.' || rel.empty?
  group = root_group
  rel.split('/').each do |segment|
    group = group[segment] || group.new_group(segment, segment)
  end
  group
end

added = []
ARGV.each do |arg|
  path = File.expand_path(arg)
  unless File.exist?(path)
    warn "skip (missing): #{path}"
    next
  end
  if existing_paths.include?(path)
    next
  end

  group = group_for(project, main_group, SOURCE_ROOT, path)
  ref = group.new_reference(path)
  target.source_build_phase.add_file_reference(ref, true) if path.end_with?('.swift')
  added << path
end

project.save
puts "Added #{added.size} file(s):"
added.each { |p| puts "  + #{Pathname.new(p).relative_path_from(Pathname.new(SOURCE_ROOT))}" }
