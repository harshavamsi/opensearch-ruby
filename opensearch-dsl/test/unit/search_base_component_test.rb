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

require 'test_helper'

module OpenSearch
  module Test
    class BaseComponentTest < ::OpenSearch::Test::UnitTestCase
      context "BaseComponent" do

        class DummyComponent
          include OpenSearch::DSL::Search::BaseComponent
        end

        class DummyComponentWithAName
          include OpenSearch::DSL::Search::BaseComponent
          name :foo
        end

        class DummyComponentWithNewName
          include OpenSearch::DSL::Search::BaseComponent
        end

        class DummyCompoundFilter
          include OpenSearch::DSL::Search::BaseCompoundFilterComponent
        end

        subject { DummyComponent.new :foo }

        should "have a name" do
          assert_equal :dummy_component, DummyComponent.new.name
        end

        should "have a custom name" do
          assert_equal :foo, DummyComponentWithAName.new.name
        end

        should "allow to set a name" do
          DummyComponentWithNewName.name :foo
          assert_equal :foo, DummyComponentWithNewName.new.name
          assert_equal :foo, DummyComponentWithNewName.name

          DummyComponentWithNewName.name = :bar
          assert_equal :bar, DummyComponentWithNewName.name
          assert_equal :bar, DummyComponentWithNewName.new.name
        end

        should "initialize the hash" do
          assert_instance_of Hash, subject.to_hash
        end

        should "have an empty Hash as args by default" do
          subject = DummyComponentWithNewName.new
          assert_equal({}, subject.instance_variable_get(:@args))
        end

        should "have an option method with args" do
          class DummyComponentWithOptionMethod
            include OpenSearch::DSL::Search::BaseComponent
            option_method :bar
          end

          subject = DummyComponentWithOptionMethod.new :foo
          assert_respond_to subject, :bar

          subject.bar 'BAM'
          assert_equal({ dummy_component_with_option_method: { foo: { bar: 'BAM' } } }, subject.to_hash)
        end

        should "keep track of option methods" do
          class DummyComponentWithCustomOptionMethod
            include OpenSearch::DSL::Search::BaseComponent
            option_method :foo
          end

          subject = DummyComponentWithCustomOptionMethod
          assert_includes subject.option_methods, :foo
        end

        should "have an option method without args" do
          class DummyComponentWithOptionMethod
            include OpenSearch::DSL::Search::BaseComponent
            option_method :bar
          end

          subject = DummyComponentWithOptionMethod.new
          assert_respond_to subject, :bar

          subject.bar 'BAM'
          assert_equal({ dummy_component_with_option_method: { bar: 'BAM' } }, subject.to_hash)
        end

        should "define a custom option method" do
          class DummyComponentWithCustomOptionMethod
            include OpenSearch::DSL::Search::BaseComponent
            option_method :bar, lambda { |*args| @hash = { :foo => 'bar' } }
          end

          subject = DummyComponentWithCustomOptionMethod.new
          subject.bar

          assert_equal 'bar', subject.instance_variable_get(:@hash)[:foo]
        end

        should "execute the passed block" do
          subject = DummyComponent.new(:foo) { @foo = 'BAR' }

          assert_respond_to  subject, :call
          assert_instance_of DummyComponent, subject.call
          assert_equal       'BAR', subject.instance_variable_get(:@foo)
        end

        should "respond to empty?" do
          assert DummyComponent.new.empty?
          assert DummyComponent.new(:foo).empty?

          subject = DummyComponent.new(:foo) { @hash = { foo: 'bar' } }
          assert ! subject.empty?
        end

        context "to_hash conversion" do

          should "build the hash with the block with args" do
            subject = DummyComponent.new :foo do
              @hash[:dummy_component][:foo].update moo: 'xoo'
            end

            assert_equal({dummy_component: { foo: { moo: 'xoo' } } }, subject.to_hash )
          end

          should "build the hash with the block without args" do
            subject = DummyComponent.new do
              @hash[:dummy_component].update moo: 'xoo'
            end

            assert_equal({dummy_component: { moo: 'xoo' } }, subject.to_hash )
          end

          should "build the hash with the option method" do
            class DummyComponentWithOptionMethod
              include OpenSearch::DSL::Search::BaseComponent
              option_method :foo
            end

            subject = DummyComponentWithOptionMethod.new do
              foo 'bar'
            end

            assert_equal({ dummy_component_with_option_method: { foo: 'bar' } }, subject.to_hash)
          end

          should "build the hash with the passed args" do
            subject = DummyComponent.new foo: 'bar'

            assert_equal({ dummy_component: { foo: 'bar' } }, subject.to_hash)
          end

          should "merge the top-level options to the hash" do
            class DummyComponentWithOptionMethod
              include OpenSearch::DSL::Search::BaseComponent
              option_method :bar
            end

            subject = DummyComponentWithOptionMethod.new :foo, xoo: 'X' do
              bar 'B'
            end

            assert_equal({ dummy_component_with_option_method: { xoo: 'X', foo: { bar: 'B' } } }, subject.to_hash)
          end

          should "return the already built hash" do
            subject = DummyComponent.new
            subject.instance_variable_set(:@hash, { foo: 'bar' })

            assert_equal({ foo: 'bar' }, subject.to_hash)
          end
        end

        context "compound filter" do
          subject { DummyCompoundFilter.new }

          should "raise an exception for unknown DSL method" do
            assert_raise(NoMethodError) { subject.foofoo }
          end
        end
      end
    end
  end
end
