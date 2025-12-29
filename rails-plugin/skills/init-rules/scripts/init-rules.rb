#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

base_dir = ARGV[0] || File.expand_path('../..', __dir__)
rules_source = "#{base_dir}/assets/rules"
rules_dest = ".claude/rules/hustler-rails"

# Detect dependencies
puts "Detecting dependencies..."
deps = []

# Gems from Gemfile.lock
if File.exist?('Gemfile.lock')
  deps += File.readlines('Gemfile.lock').map { |line| line.strip.split.first if line.start_with?('    ') }.compact
end

# Database adapter
if File.exist?('config/database.yml')
  db_config = File.read('config/database.yml')
  if db_config =~ /adapter:\s*(\w+)/
    adapter = $1
    deps << adapter
    deps << 'sqlite3' if adapter =~ /sqlite/
    deps << 'postgresql' if adapter =~ /pg/
    deps << 'mysql2' if adapter =~ /mysql/
  end
end

# JS/UI from importmap
if File.exist?('config/importmap.rb')
  deps += File.readlines('config/importmap.rb').map { |line| $1 if line =~ /pin ["']([^"']+)/ }.compact
end

# CDN assets from views
view_files = Dir.glob('app/views/**/*.html.erb') + Dir.glob('app/views/**/*.html')
view_files.each do |view_file|
  content = File.read(view_file)
  # Match CDN URLs and extract library names
  # Patterns: unpkg.com/LIBRARY@, cdn.jsdelivr.net/npm/LIBRARY@, cdnjs.cloudflare.com/ajax/libs/LIBRARY/
  cdn_libs = content.scan(%r{(?:unpkg\.com|cdn\.jsdelivr\.net/npm|cdnjs\.cloudflare\.com/ajax/libs)/([^@/\s"']+)}).flatten
  deps += cdn_libs
end

# Normalize
deps = deps.map(&:strip).map(&:downcase).uniq.reject(&:empty?)
puts "Found #{deps.size} dependencies"

# Process rule files
puts "\nProcessing rule files..."
copied = 0
skipped = 0

Dir.glob("#{rules_source}/**/*.md").reject { |f| f.end_with?('README.md') }.each do |file|
  content = File.read(file)
  rel_path = file.sub("#{rules_source}/", '')

  # Extract and parse front matter
  if content =~ /\A---\s*\n(.*?\n)---\s*\n/m
    begin
      fm = YAML.load($1)
      file_deps = fm['dependencies'] || []

      # Check if dependencies satisfied
      if file_deps.empty? || file_deps.all? { |d| deps.include?(d.downcase) }
        dest = "#{rules_dest}/#{rel_path}"
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(file, dest)
        puts "✓ #{rel_path}"
        copied += 1

        # Copy examples if specified
        if fm['examples']
          fm['examples'].each do |ex|
            ex_src = "#{rules_source}/views/examples/#{ex}"
            ex_dest = "#{rules_dest}/views/examples/#{ex}"
            if Dir.exist?(ex_src)
              FileUtils.mkdir_p(File.dirname(ex_dest))
              FileUtils.cp_r(ex_src, ex_dest)
              puts "  + example: #{ex}"
            end
          end
        end
      else
        missing = file_deps.reject { |d| deps.include?(d.downcase) }
        puts "✗ #{rel_path} (missing: #{missing.join(', ')})"
        skipped += 1
      end
    rescue => e
      puts "⚠ YAML parsing error in #{rel_path}:"
      puts "  #{e.message}"
      puts "  Frontmatter preview:"
      $1.lines.first(3).each { |line| puts "    #{line}" }
      skipped += 1
    end
  end
end

puts "\n✅ Done!"
puts "📊 Results: #{copied} copied, #{skipped} skipped"
puts "📍 Destination: #{rules_dest}/"
