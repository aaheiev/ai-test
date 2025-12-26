#!/usr/bin/env ruby

require 'json'

pods_data = JSON.parse(File.read('pods.json'))

def cpu_str_to_m(cpu_str)
    if cpu_str.end_with?("m")
        cpu_m = cpu_str.delete_suffix("m").to_i
    else
        cpu_m = cpu_str.to_i * 1000
    end
    cpu_m
end

def ram_str_to_mi(ram_str)
  return 0 unless ram_str

  if ram_str.end_with?("Mi")
    return ram_str.delete_suffix("Mi").to_i
  elsif ram_str.end_with?("Gi")
    return ram_str.delete_suffix("Gi").to_i * 1024
  else
    return 0
  end
end

def parse_containers(containers)
  pods_cpu_requests_m = 0
  pods_ram_requests_mi = 0
  container_count = 0
  containers.each do |container|
    container_count += 1
    if container["resources"]["requests"]
      pods_cpu_requests_m += cpu_str_to_m(container["resources"]["requests"]["cpu"])
      pods_ram_requests_mi += ram_str_to_mi(container["resources"]["requests"]["memory"])
    end
  end
  return { "pods_cpu_requests_m": pods_cpu_requests_m, "pods_ram_requests_mi": pods_ram_requests_mi, "container_count": container_count }
end

total_cpu_requests_m = 0
total_ram_requests_mi = 0
container_count = 0
pods_data['items'].each do |pod|
  pod_requests = parse_containers(pod["spec"]["containers"])
  total_cpu_requests_m = total_cpu_requests_m + pod_requests[:pods_cpu_requests_m].to_i
  total_ram_requests_mi = total_ram_requests_mi + pod_requests[:pods_ram_requests_mi].to_i
  container_count = container_count + pod_requests[:container_count].to_i
end

puts "=" * 60
puts "POD RESOURCE REQUEST SUMMARY"
puts "=" * 60
puts "Total Containers Analyzed: #{container_count}"
puts "-" * 60
puts "Total CPU Requests:        #{total_cpu_requests_m} mVCPU"
puts "Total Memory Requests:     #{total_ram_requests_mi} Mi"
puts "=" * 60

# puts "--------------"
# puts "Total CPU (m): #{total_cpu_requests_m}"
# puts "Total RAM (Mi): #{total_ram_requests_mi}"
