# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.
#
# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Admin client is used by tests and other rake tasks to communicate with a running cluster.
def admin_client
  $admin_client ||= begin
                      transport_options = {}
                      if (hosts = ENV['TEST_OPENSEARCH_SERVER'] || ENV['OPENSEARCH_HOSTS'])
                        split_hosts = hosts.split(',').map do |host|
                          /(http\:\/\/)?\S+/.match(host)
                        end
                        uri = URI.parse(split_hosts.first[0])
                      end

                      url = "http://#{uri&.host || 'localhost'}:#{uri&.port || 9200}"
                      puts "OpenSearch Client url: #{url}"
                      OpenSearch::Client.new(host: url, transport_options: transport_options)
                    end
end

import 'rake_tasks/opensearch_tasks.rake'
import 'rake_tasks/test_tasks.rake'
import 'rake_tasks/docker_tasks.rake'
import 'rake_tasks/update_version.rake'
import 'profile/benchmarking/benchmarking_tasks.rake'
require 'pathname'

CURRENT_PATH = Pathname(File.expand_path(__dir__))
SUBPROJECTS = [
  'opensearch',
  'opensearch-transport',
  'opensearch-dsl',
  'opensearch-api',
  'opensearch-aws-sigv4',
].freeze

RELEASE_TOGETHER = [
  'opensearch',
  'opensearch-transport',
  'opensearch-api',
  'opensearch-aws-sigv4',
].freeze

CERT_DIR = ENV['CERT_DIR']

# Import build task after setting constants:
import 'rake_tasks/unified_release_tasks.rake'

# TODO: Figure out "bundle exec or not"
# subprojects.each { |project| $LOAD_PATH.unshift CURRENT_PATH.join(project, "lib").to_s }

task :default do
  system 'rake --tasks'
end

desc "Display information about subprojects"
task :subprojects do
  puts '-' * 80
  SUBPROJECTS.each do |project|
    commit  = `git log --pretty=format:'%h %ar: %s' -1 #{project}`
    version =  Gem::Specification::load(CURRENT_PATH.join(project, "#{project}.gemspec").to_s).version.to_s
    puts "#{version}".ljust(10) +
         "| \e[1m#{project.ljust(SUBPROJECTS.map {|s| s.length}.max)}\e[0m | #{commit[ 0..80]}..."
  end
end

desc "Alias for `bundle:install`"
task :bundle => 'bundle:install'

namespace :bundle do
  desc "Run `bundle install` in all subprojects"
  task :install do
    SUBPROJECTS.each do |project|
      puts '-' * 80
      sh "cd #{CURRENT_PATH.join(project)} && unset BUNDLE_GEMFILE && bundle install"
      puts
    end
  end

  desc "Remove Gemfile.lock in all subprojects"
  task :clean do
    SUBPROJECTS.each do |project|
      sh "rm -f #{CURRENT_PATH.join(project)}/Gemfile.lock"
    end
  end
end

desc "Generate documentation for all subprojects"
task :doc do
  SUBPROJECTS.each do |project|
    sh "cd #{CURRENT_PATH.join(project)} && rake doc"
    puts '-'*80
  end
end

desc "Release all subprojects to Rubygems"
task :release do
  RELEASE_TOGETHER.each do |project|
    sh "cd #{CURRENT_PATH.join(project)} && bundle exec rake release"
    puts '-' * 80
  end
end
