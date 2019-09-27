#!/usr/bin/env ruby

require "json"
require "pry-byebug"

# TODO: show namespace defaults (limit range)
# TODO: show totals (requested, used)

module KubernetesValues
  def cpu_value(str)
    return nil if str.nil?

    case str
    when /^(\d+)$/
      $1.to_i * 1000
    when /^(\d+)m$/
      $1.to_i
    else
      raise %[CPU value: "#{str}" was not in expected format]
    end
  end

  def memory_value(str)
    return nil if str.nil?

    case str
    when /^(\d+)$/
      $1.to_i / 1_000
    when /^(\d+)k$/, /^(\d+)Ki$/
      $1.to_i / 1024
    when /^(\d+)m$/ # e.g. 6.4Gi in yaml => 6871947673600m in the JSON kubectl output
      $1.to_i / 1_000_000_000
    when /^(\d+)Gi/
      $1.to_i * 1000
    when /^(\d+)Mi/
      $1.to_i
    else
      raise %[Memory value: "#{str}" was not in expected format]
    end
  end
end


class Namespace
  attr_reader :name, :pods

  def initialize(name)
    @name = name
  end

  def get_data
    data = JSON.parse `kubectl -n #{name} get all -o json`
    @pods = get_pods(data)
    add_usage_data
    self
  end

  def to_s
    <<EOF
NAMESPACE: #{name}
PODS:
#{pods.map(&:to_s).join("\n")}
EOF
  end

  private

  def add_usage_data
    usage_data = `kubectl -n #{name} top pods --containers --no-headers`.chomp
    usage_data.split("\n").each { |line| add_container_usage(line) }
  end

  def add_container_usage(line)
    pod, container, cpu, memory = line.split(" ")
    p = pods.find { |i| i.name == pod }
    c = p.containers.find { |i| i.name == container }
    c.used = { "cpu" => cpu, "memory" => memory }
  end

  def get_pods(data)
    data.dig("items")
      .filter { |i| i.dig("kind") == "Pod" }
      .map { |pod| Pod.new(pod) }
  end
end

class Container
  attr_reader :name, :requests
  attr_accessor :used

  include KubernetesValues

  def initialize(args)
    @name = args.fetch(:name)
    @requests = args.fetch(:requests)
  end

  def to_s
    <<EOF
    #{name}
      requested (cpu, memory):\t#{req_cpu}\t#{req_mem}
      used (cpu, memory):\t#{used_cpu}\t#{used_mem}
EOF
  end

  private

  def req_mem
    memory_value requests.dig("memory")
  end

  def req_cpu
    cpu_value requests.dig("cpu")
  end

  def used_cpu
    cpu_value used.dig("cpu")
  end

  def used_mem
    memory_value used.dig("memory")
  end
end

class Pod
  attr_reader :name, :containers

  def initialize(data)
    @name = data.dig("metadata", "name")
    @containers = get_containers(data)
  end

  def to_s
    <<EOF
  POD: #{name}
#{containers.map(&:to_s).join("\n")}
EOF
  end

  private

  def get_containers(data)
    data.dig("spec", "containers").map do |c|
      name = c.dig("name")
      requests = c.dig("resources", "requests")
      Container.new(name: name, requests: requests)
    end
  end
end

############################################################

def main(namespace)
  usage if namespace.nil?
  puts Namespace.new(namespace).get_data
end

def usage
  puts <<EOF

Usage: #{$0} [namespace name]

EOF
  exit
end

main ARGV.shift
