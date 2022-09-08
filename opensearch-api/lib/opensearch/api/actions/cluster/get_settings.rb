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

module OpenSearch
  module API
    module Cluster
      module Actions
        # Returns cluster settings.
        #
        # @option arguments [Boolean] :flat_settings Return settings in flat format (default: false)
        # <b>DEPRECATED:</b> Please use <tt>cluster_manager_timeout</tt> instead.
        # @option arguments [Time] :master_timeout Explicit operation timeout for connection to master node
        # @option arguments [Time] :cluster_manager_timeout Explicit operation timeout for connection to cluster_manager node
        # @option arguments [Time] :timeout Explicit operation timeout
        # @option arguments [Boolean] :include_defaults Whether to return all default clusters setting.
        # @option arguments [Hash] :headers Custom HTTP headers
        #
        #
        def get_settings(arguments = {})
          headers = arguments.delete(:headers) || {}

          arguments = arguments.clone

          method = OpenSearch::API::HTTP_GET
          path   = "_cluster/settings"
          params = Utils.__validate_and_extract_params arguments, ParamsRegistry.get(__method__)

          body = nil
          perform_request(method, path, params, body, headers).body
        end

        # Register this action with its valid params when the module is loaded.
        #
        # @since 6.2.0
        ParamsRegistry.register(:get_settings, [
          :flat_settings,
          :master_timeout,
          :cluster_manager_timeout,
          :timeout,
          :include_defaults
        ].freeze)
      end
    end
  end
end
