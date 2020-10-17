## Prerequisites

- The uploader should be a Member/Admin of the developer account.
    - One can confirm by looking at `Xcode` -> `Preferences` -> `Accounts` and see if there is an non-personal team name.
- Make sure the app builds with no warnings or issues. Build setup can be found [here](./build-setup.md)
- Update the following properties of the app
    - Check if Bundle Identifier is `edu.duke.mobilecenter.Jigsaw.beta`. This will allow us to test the app without occupying the Bundle Identifier for release to AppStore (i.e. `edu.duke.mobilecenter.Jigsaw`).
- If this is the first time to upload the app, be sure the app is also created on App Store Connect.
    - In the `Apps` [tab](https://appstoreconnect.apple.com/apps), tap the add button to create an app.
    - Fill in the required information. Please note: it is recommended to use different bundle identifiers for test and release version, so that both versions can live together on a same device, to better serve for testing purpose.
    - ⚠️ Xcode won't allow you to upload unless you've done this step.

## Steps

1. Archive the app

    Open your project in Xcode, make sure you have done the prerequisites. Choose `Generic iOS Device` in the scheme chooser. Then choose `Product` -> `Archive`. Archiving the app will take a few minutes.
![After archive](https://user-images.githubusercontent.com/9660181/93394482-25380f80-f829-11ea-9b6e-23c07b8a1d11.png)

    **Note**: if the archive option is grayed out, make sure you've selected the `Generic iOS Device` in scheme.

    It will take more than 10 minutes to archive the current version of the app, due to the Firebase dependencies. During the archive process, You may see warnings as the screenshot below. This is due to an Xcode [issue](https://developer.apple.com/forums/thread/130677) and is safe to ignore for Xcode 11.
![Warnings](https://user-images.githubusercontent.com/9660181/93305022-c932a400-f7b2-11ea-86bd-4b1083f04378.png)

2. Pre-upload

    - If everything is OK with the build, Xcode will open the  Organizer window with your app in the Archives tab. Click `Distribute App` with the correct archive version.
    - In the sheet that appears, select `App Store Connect` as the distribution method, click next and choose `Upload` and click next.
![App Store Connect](https://user-images.githubusercontent.com/9660181/93394479-2406e280-f829-11ea-8fad-2bf87f823d21.png)
    - Leave all distribution options checked by default
![Default checkboxes](https://user-images.githubusercontent.com/9660181/93275828-d039c200-f772-11ea-9677-c59be4e54734.png)
    - For TestFlight, it is OK to use `Automatically manage signing`. Click next and wait for Apple's magic...
![Auto signing](https://user-images.githubusercontent.com/9660181/93275836-d62fa300-f772-11ea-9769-90b4b1587c11.png)
    
    **Note**: if you see the screenshot below, it means you are not enrolled in the [Apple Developer Program](https://developer.apple.com/programs/enroll/).
![Not enrolled](https://user-images.githubusercontent.com/9660181/93394473-223d1f00-f829-11ea-8ccb-2ca90992361b.png)

3. Review app signage information

    Review all the information in the summary and entitlement sections. Make sure the signing certificate, provisioning profile and entitlements are correct. Then click upload. It will take a few minute before the app will appear in the [TestFlight tab](https://appstoreconnect.apple.com/apps/1180714771/testflight/ios) on App Store Connect.

![Entitlement](https://user-images.githubusercontent.com/9660181/93276189-c82e5200-f773-11ea-8b57-4201bbd1a94e.png)

![Uploading](https://user-images.githubusercontent.com/9660181/93276192-cb294280-f773-11ea-909c-83acf690e3ef.png)

![Upload success](https://user-images.githubusercontent.com/9660181/93276194-ccf30600-f773-11ea-9035-5e817d9a3a6a.png)

4. Assign testers

![Processing](https://user-images.githubusercontent.com/9660181/93276337-1c393680-f774-11ea-83c0-09692d9fad5d.png)

After processing is done, you will receive an email indicating it can be used as a TestFlight version or release to public AppStore. For now we only use it for TestFlight. For ⚠️ `Missing Compliance` warning, simply select `No` for now.

We only want Internal Testers for pre-release beta tests. Add internal testers via `Internal Group` -> `App Store Connect Users` tab on the left. The testers will receive an email about the test version, and they can access it via `TestFlight` which can be downloaded from [AppStore](https://apps.apple.com/us/app/testflight/id899247664).

Redeem the test version in app and voilà! Now you can play with the latest version and see if it is good to release. Be aware - since the beta app shares the same bundle identifier with our released app, it will replace the existing AppStore version from last release. 🎉 

## References

1. [Upload an app to App Store Connect](https://help.apple.com/xcode/mac/current/#/dev442d7f2ca)
2. [TestFlight panel of Runtime SDK Samples App](https://appstoreconnect.apple.com/apps/1180714771/testflight)
3. [TestFlight Tutorial](https://www.raywenderlich.com/5352-testflight-tutorial-ios-beta-testing)

```
version: 201017 Ting Chen
```