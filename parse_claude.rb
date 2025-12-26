#!/usr/bin/env ruby

require 'json'

# Helper function to convert CPU strings to mini vCPU
def parse_cpu(cpu_str)
  return 0 if cpu_str.nil? || cpu_str.empty?

  cpu_str = cpu_str.strip

  if cpu_str.end_with?('m')
    # Millicores: 500m = 500 millicores = 500,000 mini vCPUs
    millicores = cpu_str.chomp('m').to_f
    (millicores).to_i
  else
    # Full vCPU: 1 = 1,000 mini vCPUs
    vcpus = cpu_str.to_f
    (vcpus * 1_000).to_i
  end
end

# Helper function to convert memory strings to Mi
def parse_memory(memory_str)
  return 0 if memory_str.nil? || memory_str.empty?

  memory_str = memory_str.strip

  case memory_str
  when /(\d+(?:\.\d+)?)Ki$/
    # Kibibytes to Mebibytes
    (Regexp.last_match(1).to_f / 1024).to_i
  when /(\d+(?:\.\d+)?)Mi$/
    # Already in Mebibytes
    Regexp.last_match(1).to_i
  when /(\d+(?:\.\d+)?)Gi$/
    # Gibibytes to Mebibytes
    (Regexp.last_match(1).to_f * 1024).to_i
  when /(\d+(?:\.\d+)?)Ti$/
    # Tebibytes to Mebibytes
    (Regexp.last_match(1).to_f * 1024 * 1024).to_i
  else
    # Assume bytes if no unit
    (memory_str.to_f / (1024 * 1024)).to_i
  end
end

# Parse pods.json and summarize CPU and memory requests
data = JSON.parse(File.read('pods.json'))

total_cpu_mini_vcpu = 0
total_memory_mi = 0
container_count = 0

data['items'].each do |pod|
  namespace = pod['metadata']['namespace']
  pod_name = pod['metadata']['name']
  containers = pod['spec']['containers'] || []

  containers.each do |container|
    resources = container['resources'] || {}
    requests = resources['requests'] || {}

    # Extract CPU request (default to 0 if not specified)
    cpu_str = requests['cpu'] || '0'
    cpu_mini_vcpu = parse_cpu(cpu_str)
    total_cpu_mini_vcpu += cpu_mini_vcpu

    # Extract memory request (default to 0 if not specified)
    memory_str = requests['memory'] || '0'
    memory_mi = parse_memory(memory_str)
    total_memory_mi += memory_mi

    container_count += 1
  end
end

puts "=" * 60
puts "POD RESOURCE REQUEST SUMMARY"
puts "=" * 60
puts "Total Containers Analyzed: #{container_count}"
puts "-" * 60
puts "Total CPU Requests:        #{total_cpu_mini_vcpu} mVCPU"
puts "Total Memory Requests:     #{total_memory_mi} Mi"
puts "=" * 60
