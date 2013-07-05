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

require 'java_buildpack/framework'
require 'rexml/document'
require 'rexml/formatters/pretty'

module JavaBuildpack::Framework

  # A class that encapsulates the modification of a +web.xml+ Servlet configuration file for the Spring Auto-
  # reconfiguration framework.
  class WebXmlModifier

    # Creates a new instance of the modifier.
    #
    # @param [{REXML::Document}, String, {IO}] source the content of the +web.xml+ file to modify
    def initialize(source)
      @document = REXML::Document.new(source)
    end

    def context_loader_listener
      if has_context_loader_listener?
        locations_string = context_config_locations

        locations = locations_string.value.strip.split(/[,;\s]+/)
        locations << CONTEXT_LOCATION_ADDITIONAL

        locations_string.value = locations.join(' ')
      end
    end

    # Returns a +String+ representation of the modified +web.xml+.
    #
    # @return [String] a +String+ representation of the modified +web.xml+.
    def to_s
      @document.to_s
    end

    private

    CONTEXT_CONFIG_LOCATION = 'contextConfigLocation'.freeze

    CONTEXT_LOADER_LISTENER = 'org.springframework.web.context.ContextLoaderListener'.freeze

    CONTEXT_LOCATION_ADDITIONAL = 'classpath:META-INF/cloud/cloudfoundry-auto-reconfiguration-context.xml'.freeze

    CONTEXT_LOCATION_DEFAULT = '/WEB-INF/applicationContext.xml'.freeze

    def context_config_locations
      locations = xpath("/web-app/context-param[param-name[contains(text(), '#{CONTEXT_CONFIG_LOCATION}')]]/param-value/text()").first
      locations = create_context_config_locations if !locations
      locations
    end

    def create_context_config_locations
      web_app = xpath("/web-app").first
      context_param = REXML::Element.new 'context-param', web_app

      param_name = REXML::Element.new 'param-name', context_param
      REXML::Text.new CONTEXT_CONFIG_LOCATION, true, param_name

      param_value = REXML::Element.new 'param-value', context_param
      location = REXML::Text.new CONTEXT_LOCATION_DEFAULT, true, param_value

      location
    end

    def has_context_loader_listener?
      xpath("/web-app/listener/listener-class[contains(text(), '#{CONTEXT_LOADER_LISTENER}')]").any?
    end

    def xpath(path)
      REXML::XPath.match(@document, path)
    end

  end

end
