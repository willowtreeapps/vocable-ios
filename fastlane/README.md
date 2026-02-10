fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test_unit_ui

```sh
[bundle exec] fastlane ios test_unit_ui
```

Runs Unit and UI tests

### ios adhoc

```sh
[bundle exec] fastlane ios adhoc
```

Ad-hoc build

### ios build_deploy_testflight

```sh
[bundle exec] fastlane ios build_deploy_testflight
```

AppStore build and upload to TestFlight

### ios wt_register_new_device

```sh
[bundle exec] fastlane ios wt_register_new_device
```

Add devices via the command line to the device portal and regenerate the development provisioning profile with the device

### ios wt_setup_build_environment

```sh
[bundle exec] fastlane ios wt_setup_build_environment
```

Setup local development environment (WillowTree Internal)

Renew development certificates using App Store Connect API key (use when behind SSO)

### ios match_development
In your terminal, navigate to the vocable-ios project folder.  Run the following commands:

Values can be found in 1password in "Fastlane Match + CircleCI Secrets" in the Vocable vault.

```sh
export APP_STORE_CONNECT_API_KEY_KEY_ID="..."
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="..."
export APP_STORE_CONNECT_API_KEY_KEY_BASE64="..."   # base64 string
export APP_STORE_CONNECT_TEAM_ID="..."
[bundle exec] fastlane ios match_development
```



### ios match_appstore
Renew App Store / deployment certificates using App Store Connect API key (use when behind SSO)
In your terminal, navigate to the vocable-ios project folder.  Run the following commands:

Values can be found in 1password in "Fastlane Match + CircleCI Secrets" in the Vocable vault.

```sh
export APP_STORE_CONNECT_API_KEY_KEY_ID="..."
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="..."
export APP_STORE_CONNECT_API_KEY_KEY_BASE64="..."   # base64 string
export APP_STORE_CONNECT_TEAM_ID="..."
[bundle exec] fastlane ios match_appstore
```

### ios xliff_import

```sh
[bundle exec] fastlane ios xliff_import
```

Integrate latest XLIFF files with project

### ios xcstrings_import

```sh
[bundle exec] fastlane ios xcstrings_import
```

Integrate latest xcstrings files from Crowdin

### ios xliff_export

```sh
[bundle exec] fastlane ios xliff_export
```

Export current XLIFF file from project

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).


