# get_version_code plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-get_version_code)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-get_version_code`, add it to your project by running:

```bash
fastlane add_plugin get_version_code
```

## About get_version_code

Get the version code of an Android project. This action will return the version code of your project according to the one set in your build.gradle file. It supports product flavors to get flavor-specific version codes.

### Features

- Extract version code from build.gradle files
- Support for custom app folder names
- Support for custom gradle file paths
- Support for external constants
- **NEW**: Support for product flavors to get flavor-specific version codes

### Parameters

| Key | Description | Default |
|-----|-------------|---------|
| `app_folder_name` | The name of the application source folder in the Android project | `"app"` |
| `gradle_file_path` | The relative path to the gradle file containing the version code parameter | `nil` |
| `ext_constant_name` | If the version code is set in an ext constant, specify the constant name | `"versionCode"` |
| `product_flavor` | The product flavor name to search for specific version code | `nil` |

## Usage Examples

### Basic Usage

```ruby
# Get version code from default app/build.gradle
version_code = get_version_code

# Get version code from custom folder
version_code = get_version_code(
  app_folder_name: "myapp"
)

# Get version code from specific gradle file path
version_code = get_version_code(
  gradle_file_path: "app/build.gradle"
)
```

### Product Flavors Support

```ruby
# Get version code for a specific product flavor
version_code = get_version_code(
  product_flavor: "production"
)

# Get version code for a flavor with custom app folder
version_code = get_version_code(
  app_folder_name: "myapp",
  product_flavor: "staging"
)
```

### Example build.gradle with Product Flavors

```gradle
android {
    compileSdkVersion 30

    defaultConfig {
        applicationId "com.example.myapp"
        minSdkVersion 21
        targetSdkVersion 30
        versionCode 1
        versionName "1.0"
    }

    productFlavors {
        production {
            versionCode 100
            versionName "1.0.0"
        }
        
        staging {
            versionCode 101
            versionName "1.0.1-staging"
        }
        
        development {
            versionCode 102
            versionName "1.0.2-dev"
        }
    }
}
```

When using `get_version_code(product_flavor: "production")`, it will return `100` instead of the default `1`.

## Example Fastfile

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use 
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
# fastlane-plugin-get_version_code
