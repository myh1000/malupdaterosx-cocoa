 [![License](https://img.shields.io/badge/license-BSD-green.svg)](http://opensource.org/licenses/BSD-3-Clause)

# MAL Updater OS X 2.3
MAL Updater OS X is an open source OS X scrobbler that automatically detects what's playing and updates the user's MyAnimeList.

XCode 8 or higher is required to build (Deployment Target is OS X 10.9)

Like this program and want to support the development of this program? [Become our Patreon](http://www.patreon.com/ateliershiori) or [Donate](https://malupdaterosx.ateliershiori.moe/donate/)

Note: Starting with MAL Updater OS X 2.2.7.1, the application is now Developer ID signed. In order to build, you need to have an Apple Developer ID certificate. Otherwise, you would need to disable code signing.

## How to use
Check the [Getting Started Guide](https://github.com/chikorita157/malupdaterosx-cocoa/wiki/Getting-Started)

## How to Compile in XCode
1. Get the Source
2. Type 'xcodebuild' to build. The build will be in the build/release folder.

## Dependencies
All the frameworks are included. Just build! Here are the frameworks that are used in this app:

* anitomy-osx.framework (MPL Licensed, included as a submodule)
* EasyNSURLConnection.framework
* MASPreferences.framework
* MASShortcut.framework
* Sparkle.framework
* OgreKit.framework

##License
Unless stated, Source code is licensed under [New BSD License](https://github.com/Atelier-Shiori/malupdaterosx-cocoa/blob/master/License.md).
