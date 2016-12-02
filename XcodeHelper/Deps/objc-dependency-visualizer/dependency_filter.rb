#!/usr/bin/env ruby
# encoding: UTF-8

require 'optparse'
require 'json'
require 'set'

def get_file_last_string(filename)
  data = ''
  f = File.open(filename, 'r')
  f.each_line do |line|
      data = line
  end

  return data
end

##### MAIN #####

options = {}

#Defaults
options[:jsfile_path] = 'origin.js.bak'
options[:regex] = '.*'
options[:ouput] = 'origin.js'

parser = OptionParser.new do |o|
    o.separator 'General options:'
    o.on('-p PATH', '--path' ,'Path for origin file') { |path|
      options[:jsfile_path] = path
    }
    o.on('-r REGEX', 'Regex for filter links') { |regex|
      options[:regex] = regex
    }
    o.on('-o OUTPUT_FILE', 'Output file name') { |file|
      options[:ouput] = file
    }

    o.separator 'Common options:'
    o.on_tail('-h', 'Prints this help') { puts o; exit }
    o.parse!

end

json_string = get_file_last_string(options[:jsfile_path])
obj = JSON.parse(json_string)

links_count = obj['links_count']
source_files_count = obj['source_files_count']
links = obj['links']

regex = options[:regex]

source_set = Set.new
result_links = []
links.each do |link|
    source = link['source']
    dest = link['dest']

    if source.match(regex) || dest.match(regex)
        source_set << source
        result_links << link
    end
end
result_source_files_count = source_set.length
result_links_count = result_links.length

json_result = {}
json_result['links'] = result_links
json_result['source_files_count'] = result_source_files_count
json_result['links_count'] = result_links_count

result = ''
result += <<-THEEND
var dependencies =
THEEND
result += json_result.to_json

target = File.open(options[:ouput], 'w')
target.write("#{result}")
