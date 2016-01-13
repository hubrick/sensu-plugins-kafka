#! /usr/bin/env ruby
#
# check-topics
#
# DESCRIPTION:
#   This plugin checks for partition issues
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   ./check-topics.rb -o OPTION
#
# NOTES:
#
# LICENSE:
#   Olivier Bazoud
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

class KafkaTopics < Sensu::Plugin::Check::CLI
  option :kafka_home,
         description: 'Kafka home',
         short:       '-k NAME',
         long:        '--kafka-home NAME',
         default:     '/opt/kafka'

  option :zookeeper,
         description: 'ZooKeeper connect string',
         short:       '-z NAME',
         long:        '--zookeeper NAME',
         default:     'localhost:2181'

  option :option,
         description: 'option',
         short:       '-o OPTION',
         long:        '--option OPTION',
         required:    true,
         in:          ['unavailable-partitions', 'under-replicated-partitions']

  def run
    kafka_run_class = "#{config[:kafka_home]}/bin/kafka-topics.sh"
    unknown "Can not find #{kafka_run_class}" unless File.exist?(kafka_run_class)

    cmd = "#{kafka_run_class} --zookeeper #{config[:zookeeper]} --describe --#{config[:option]}"

    results = %x(#{cmd})

    send :critical, results.join("\n") unless results.empty?

    ok "No #{config[:option].gsub(/-/, ' ')}"
  rescue => e
    puts "Error: exception: #{e}"
    puts "Error: exception: #{e.backtrace}"
    critical
  end
end
