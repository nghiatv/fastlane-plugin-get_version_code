module Fastlane
  module Actions
    class GetVersionCodeAction < Action
      def self.run(params)
        version_code = "0"

        constant_name ||= params[:ext_constant_name]
        gradle_file_path ||= params[:gradle_file_path]
        product_flavor ||= params[:product_flavor]
        if gradle_file_path != nil
            UI.message("The get_version_code plugin will use gradle file at (#{gradle_file_path})!")
            version_code = getVersionCode(gradle_file_path, constant_name, product_flavor)
        else
            app_folder_name ||= params[:app_folder_name]
            UI.message("The get_version_code plugin is looking inside your project folder (#{app_folder_name})!")

            #temp_file = Tempfile.new('fastlaneIncrementVersionCode')
            #foundVersionCode = "false"
            Dir.glob("**/#{app_folder_name}/build.gradle") do |path|
                UI.message(" -> Found a build.gradle file at path: (#{path})!")
                version_code = getVersionCode(path, constant_name, product_flavor)
            end
        end

        if version_code == "0"
            UI.user_error!("Impossible to find the version code in the current project folder #{app_folder_name} 😭")
        else
            # Store the version name in the shared hash
            Actions.lane_context["VERSION_CODE"]=version_code
            UI.success("👍 Version name found: #{version_code}")
        end

        return version_code
      end

      def self.getVersionCode(path, constant_name, product_flavor)
          version_code = "0"
          if !File.file?(path)
              UI.message(" -> No file exist at path: (#{path})!")
              return version_code
          end
          begin
              file_content = File.read(path)
              
              # If product_flavor is specified, look for version code within that flavor block first
              if product_flavor && !product_flavor.empty?
                  UI.message(" -> Looking for version code in product flavor: #{product_flavor}")
                  
                  # First find the productFlavors block
                  product_flavors_pattern = /productFlavors\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}/m
                  product_flavors_match = file_content.match(product_flavors_pattern)
                  
                  if product_flavors_match
                      product_flavors_content = product_flavors_match[1]
                      
                      # Then find the specific flavor within productFlavors block
                      flavor_pattern = /#{product_flavor}\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}/m
                      flavor_match = product_flavors_content.match(flavor_pattern)
                      
                      if flavor_match
                          flavor_content = flavor_match[1]
                          # Look for versionCode in the flavor content only
                          version_code_pattern = /#{constant_name}\s+(\d+)/
                          version_match = flavor_content.match(version_code_pattern)
                          if version_match
                              version_code = version_match[1]
                              UI.message(" -> Found version code in flavor #{product_flavor}: #{version_code}")
                          else
                              UI.message(" -> No version code found in flavor #{product_flavor}, trying defaultConfig")
                          end
                      else
                          UI.message(" -> Product flavor #{product_flavor} not found in productFlavors block, trying defaultConfig")
                      end
                  else
                      UI.message(" -> No productFlavors block found in gradle file, trying defaultConfig")
                  end
                  
                  # If version code not found in flavor, fallback to defaultConfig
                  if version_code == "0"
                      UI.message(" -> Falling back to defaultConfig")
                      default_config_pattern = /defaultConfig\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}/m
                      default_config_match = file_content.match(default_config_pattern)
                      
                      if default_config_match
                          default_config_content = default_config_match[1]
                          version_code_pattern = /#{constant_name}\s+(\d+)/
                          version_match = default_config_content.match(version_code_pattern)
                          if version_match
                              version_code = version_match[1]
                              UI.message(" -> Found version code in defaultConfig: #{version_code}")
                          else
                              UI.message(" -> No version code found in defaultConfig either")
                          end
                      else
                          UI.message(" -> No defaultConfig block found")
                      end
                  end
              end
              
              # If no product_flavor specified or flavor-specific search failed, use original logic
              if version_code == "0"
                  file_content.each_line do |line|
                      if line.include? constant_name
                         versionComponents = line.strip.split(' ')
                         version_code = versionComponents[versionComponents.length - 1].tr("\"","")
                         break
                      end
                  end
              end
              
          rescue => err
              UI.error("An exception occured while reading gradle file: #{err}")
              err
          end
          return version_code
      end

      def self.description
        "Get the version code of an Android project. This action will return the version code of your project according to the one set in your build.gradle file. Supports product flavors to get flavor-specific version codes."
      end

      def self.authors
        ["Jems"]
      end

      def self.available_options
          [
            FastlaneCore::ConfigItem.new(key: :app_folder_name,
                                    env_name: "GETVERSIONCODE_APP_FOLDER_NAME",
                                 description: "The name of the application source folder in the Android project (default: app)",
                                    optional: true,
                                        type: String,
                               default_value:"app"),
            FastlaneCore::ConfigItem.new(key: :gradle_file_path,
                                    env_name: "GETVERSIONCODE_GRADLE_FILE_PATH",
                                 description: "The relative path to the gradle file containing the version code parameter (default:app/build.gradle)",
                                    optional: true,
                                        type: String,
                               default_value: nil),
             FastlaneCore::ConfigItem.new(key: :ext_constant_name,
                                     env_name: "GETVERSIONCODE_EXT_CONSTANT_NAME",
                                  description: "If the version code is set in an ext constant, specify the constant name (optional)",
                                     optional: true,
                                         type: String,
                                default_value: "versionCode"),
             FastlaneCore::ConfigItem.new(key: :product_flavor,
                                     env_name: "GETVERSIONCODE_PRODUCT_FLAVOR",
                                  description: "The product flavor name to search for specific version code (optional)",
                                     optional: true,
                                         type: String,
                                default_value: nil)
          ]
        end

        def self.output
          [
            ['VERSION_CODE', 'The version code of the project']
          ]
        end

        def self.is_supported?(platform)
          [:android].include?(platform)
        end
    end
  end
end
