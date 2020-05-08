fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios lint
```
fastlane ios lint
```
Run swiftlint
### ios adhoc
```
fastlane ios adhoc
```
Ad-hoc build
### ios buildanddeploytotestflight
```
fastlane ios buildanddeploytotestflight
```
AppStore build and upload to TestFlight
### ios register
```
fastlane ios register
```
Add devices via the command line to the device portal and regenerate the development provisioning profile with the device
### ios xliffimport
```
fastlane ios xliffimport
```
Integrate latest XLIFF files with project

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
