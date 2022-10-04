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
    module Snapshot
      module Actions
        # Returns information about a repository.
        #
        # @option arguments [List] :repository A comma-separated list of repository names
        # <b>DEPRECATED:</b> Please use <tt>cluster_manager_timeout</tt> instead.
        # @option arguments [Time] :cluster_manager_timeout Explicit operation timeout for connection to cluster_manager node
        # @option arguments [Boolean] :local Return local information, do not retrieve the state from cluster_manager node (default: false)
        # @option arguments [Hash] :headers Custom HTTP headers
        #
        #
        def get_repository(arguments = {})
          headers = arguments.delete(:headers) || {}

          arguments = arguments.clone

          _repository = arguments.delete(:repository)

          method = OpenSearch::API::HTTP_GET
          path   = if _repository
                     "_snapshot/#{Utils.__listify(_repository)}"
                   else
                     "_snapshot"
                   end
          params = Utils.__validate_and_extract_params arguments, ParamsRegistry.get(__method__)

          body = nil
          if Array(arguments[:ignore]).include?(404)
            Utils.__rescue_from_not_found { perform_request(method, path, params, body, headers).body }
          else
            perform_request(method, path, params, body, headers).body
          end
        end

        # Register this action with its valid params when the module is loaded.
        #
        # @since 6.2.0
        ParamsRegistry.register(:get_repository, [
          :master_timeout,
          :cluster_manager_timeout,
          :local
        ].freeze)
      end
    end
  end
end
