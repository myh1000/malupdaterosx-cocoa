 [![License](https://img.shields.io/badge/license-BSD-green.svg)](http://opensource.org/licenses/BSD-3-Clause)

# MAL Updater OS X 2.3
MAL Updater OS X is an open source OS X scrobbler that automatically detects what's playing and updates the user's MyAnimeList.

Forked to add support for manga and multiple sites.

Now also with support for /r/manga.

XCode 7 or higher is required to build (Deployment Target is OS X 10.8)

## Supporting this Project

Like this program and want to support the development of this program? [Become our Patreon](http://www.patreon.com/ateliershiori) or [Donate](https://malupdaterosx.ateliershiori.moe/donate/). By donating more than $5 or becoming a patron, you will recieve a donation key to remove the reminder message.

You can also donate cryptocurrencies to these addresses (send an email with the transaction ID and address to get a donation key as long the amount is equilivant to $5 USD or more):
* Bitcoin - Use the Bitpay form on the [donation page](https://malupdaterosx.ateliershiori.moe/donate/).
* Ethereum - 7DDfd7443d3D4A7ec76e25d481E68BE43533b509

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
