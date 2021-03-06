# Cloud Foundry Java Buildpack
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/jre'
require 'java_buildpack/jre/memory/weight_balancing_memory_heuristic'

module JavaBuildpack::Jre

  # A utility for calculating the memory settings for OpenJDK < 1.8.0
  class MemoryHeuristicsOpenJDKPre8 < WeightBalancingMemoryHeuristic

    # Creates an instance based on a hash containing memory settings, a configuration file containing weightings, and
    # the application's memory size in $MEMORY_LIMIT.
    #
    # @param [Hash<String, Numeric>] sizes any sizings specified by the user
    # @param [Hash<String, Numeric>] heuristics the memory heuristics for OpenJDK
    def initialize(sizes, heuristics)
      super(sizes, heuristics, VALID_SIZES, VALID_HEURISTICS, JAVA_OPTS)
    end

    private

    JAVA_OPTS = {
      'heap' => '-Xmx',
      'permgen' => '-XX:MaxPermSize=',
      'stack' => '-Xss',
    }.freeze

    VALID_HEURISTICS = ['heap', 'permgen', 'stack', 'native']

    VALID_SIZES = ['heap', 'permgen', 'stack']

  end

end
