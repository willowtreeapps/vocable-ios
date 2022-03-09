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

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs all the tests

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run swiftlint

### ios adhoc

```sh
[bundle exec] fastlane ios adhoc
```

Ad-hoc build

### ios buildanddeploytotestflight

```sh
[bundle exec] fastlane ios buildanddeploytotestflight
```

AppStore build and upload to TestFlight

### ios register

```sh
[bundle exec] fastlane ios register
```

Add devices via the command line to the device portal and regenerate the development provisioning profile with the device

### ios xliffimport

```sh
[bundle exec] fastlane ios xliffimport
```

Integrate latest XLIFF files with project

### ios xliffexport

```sh
[bundle exec] fastlane ios xliffexport
```

Export current XLIFF file from project

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
