# frozen_string_literal: true

require "dependabot/gradle/file_updater"
require "dependabot/gradle/file_parser/property_value_finder"

module Dependabot
  module Gradle
    class FileUpdater
      class GradlePropertyValueUpdater
        def initialize(dependency_files:)
          @dependency_files = dependency_files
        end

        def update_files_for_property_change(property_name:,
                                             callsite_buildfile:,
                                             previous_value:,
                                             updated_value:)

          filename = callsite_buildfile.name
          file_to_update = dependency_files.find { |f| f.name == filename }

          updated_content = file_to_update.content.sub(
            "#{property_name}=#{previous_value}",
            "#{property_name}=#{updated_value}"
          )

          updated_files = dependency_files.dup
          updated_files[updated_files.index(file_to_update)] =
            update_file(file: file_to_update, content: updated_content)

          updated_files
        end

        private

        attr_reader :dependency_files

        def property_value_finder
          @property_value_finder ||=
            Gradle::FileParser::PropertyValueFinder.
            new(dependency_files: dependency_files)
        end

        def update_file(file:, content:)
          updated_file = file.dup
          updated_file.content = content
          updated_file
        end

        def previous_value_regex(previous_value)
          /(?<=['"])#{Regexp.quote(previous_value)}(?=['"])/
        end
      end
    end
  end
end
