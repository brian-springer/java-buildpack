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

require 'spec_helper'
require 'java_buildpack/framework/spring_auto_reconfiguration/web_xml_modifier'
require 'rexml/document'

module JavaBuildpack::Framework

  describe WebXmlModifier, :focus do

    it 'should not modify if there is no ContextLoaderListener' do
      assert_equality('web_no_ContextLoaderListener.xml', 'web_no_ContextLoaderListener.xml') do |modifier|
        modifier.context_loader_listener
      end
    end

    it 'should update a contextConfigLocation if there is a ContextLoaderListener' do
      assert_equality('web_contextConfigLocation.xml', 'web_additional_contextConfigLocation.xml') do |modifier|
        modifier.context_loader_listener
      end
    end

    it 'should add a missing contextConfigLocation if there is a ContextLoaderListener' do
      assert_equality('web_only_ContextLoaderListener.xml', 'web_default_contextConfigLocation.xml') do |modifier|
        modifier.context_loader_listener
      end
    end

    private

    def assert_equality(input, output, &block)
      modifier = File.open("spec/fixtures/#{input}") do |file|
        WebXmlModifier.new(file)
      end

      block.call modifier

      expected = File.open("spec/fixtures/#{output}") { |file| file.read }
      actual = modifier.to_s

      expect(actual).to eq(expected)
    end

  end

end
