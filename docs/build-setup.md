# Build setup notes

> This is a temporary version of build setup instructions. When Apple's [ResearchKit](https://github.com/ResearchKit/ResearchKit) release version 2.1 on CocoaPods, this doc will be updated.

## Download or Pull

- If you prefer pull or clone to download, run `git clone git@github.com:DukeMobileDevCenter/Jigsaw.git` to get the code.
- If to download, use this link: https://github.com/DukeMobileDevCenter/Jigsaw/archive/dev.zip
- Refer to [this](https://github.com/DukeMobileDevCenter/Jigsaw/tree/dev) branch `dev` for source code.

## Prerequisites

These tools are needed to setup the dependencies for this app. To install them and build this app, you'll need HomeBrew and CocoaPods installed.

### Basics

- Make sure your Xcode is on latest version 11.6.
- Better to also have latest macOS.
- HomeBrew if not already.

### CocoaPods

- https://cocoapods.org/
- The default installation is `sudo gem install cocoapods`
- The easy way to install is `brew install cocoapods`
- Note for some Macs upgraded from 10.14 Mojave, the Ruby dependency might be an issue. Please sort it out. 😏 

### (Optional) SwiftLint

I've opt-ed in a linter for this project to enforce myself practicing good coding style.

- https://github.com/realm/SwiftLint
- The easy way to install is `brew install swiftlint`

---

## Initialize the environment

Under `Jigsaw-app` folder, run the following shell commands.

```sh
$ pod install
```

It should take a few to ten more minutes to setup these dependencies. (13 minutes for pods, 10 minutes for first indexing in project on low end MacBook Air 💻 )

## Build and run the app

Simply click run button in the project. Rename the bundle identifier if you need to sign and install on a device. (Don't use the bundle id without beta - I want to reserve it for release. 😅)

The interface design is based on iPhone 11, and it is encouraged to check if they also look good with other dimensions.

## Play with the app

Most of the steps should be intuitive.

## Reference

- [Issue#39](https://github.com/DukeMobileDevCenter/Jigsaw/issues/39)

---

Last update: 201017
