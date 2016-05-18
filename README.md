## OpenTok Crash Test

This repo demonstrates a crash in the [OpenTok iOS SDK](https://www.tokbox.com/developer/sdks/ios/) when using a custom [OTVideoCapture](https://tokbox.com/developer/sdks/ios/reference/Protocols/OTVideoCapture.html) for [OTPublisherKit](https://www.tokbox.com/developer/sdks/ios/reference/Classes/OTPublisherKit.html#//api/name/videoCapture]). This specifically applies to ARC-enabled projects (which Swift is automatically), but could also present issues in non-ARC projects.

#### Crash Details

###### Note: There is an update to these details, see [additional details](#additional-details) below.

When setting up `OTPublisherKit` to publish to an `OTSession`, if you provide your own `OTVideoCapture` object, there is a crash when everything is cleaned up and shut down. There is some interesting memory management issues going on here. If you just create the capture device and assign it like this:

```swift
func setupCapture() {
    let videoCapture = OpenTokVideoCapturer()
    publisher?.videoCapture = videoCapture
}
```

The `videoCapture` property on the publisher is actually deallocated immediately, once it is out of the current scope. So, when the publisher tries to do anything with the capture device, it causes a crash trying to reference a deallocated object. You can keep the capture object around, by using a property which holds a strong reference to it, like so:

```swift
var videoCapture: OpenTokVideoCapturer? = nil

func setupCapture() {
    videoCapture = OpenTokVideoCapturer()
    publisher?.videoCapture = videoCapture
}
```

And this will keep the capture device around for the publisher to use, and keeps it happy for a while. However, ARC magically releases `videoCapture` when the parent object is deallocated, and there is also a release somewhere in the publisher when it gets cleaned up as well, causing it to be over-released and a crash by trying to release a deallocated object, yet again.

Pretty much all of the sample code for doing this (including the [sample code](https://github.com/opentok/learning-opentok-ios/blob/video-capturer-basic/LearningOpenTok/ViewController.m#L131)) that I've seen has been in Objective-C, presumably with ARC not enabled, looks something like this:

```objc
publisher.videoCapture = [[OpenTokVideoCapturer alloc] init];
```

...Which violates the [Cocoa Memory Management Policy](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmRules.html), because this should look like this:

```objc
publisher.videoCapture = [[[OpenTokVideoCapturer alloc] init] autorelease];
```

In summary, the SDK is over-releasing `videoCapture`, and it is just working okay because most code using it is based off of the sample code and happens to leak. So the SDK is accidentally plugging the leak...But this causes a crash on applications that manage memory correctly, or are using ARC.

#### Reproducing

1. Clone this repo.
2. Run `pod install`.
3. Open the workspace and run.
4. Tap the go button.
5. Wait a few seconds for OpenTok to initialize and connect.
6. Tap the back button on the top navigation bar.
7. Observe the crash.

#### Workaround

For anyone using Swift, I've added an example of a simple hack to workaround this issue to the project. Simply uncomment [TokViewController.swift#L77](https://github.com/dbburgess/opentok-crash-test/blob/master/OpenTok-Crash-Test/TokViewController.swift#L77) to see it in action. All it is doing is performing a retain to +1 the reference count without a corresponding release, to match the behavior of the above sample Objective-C code. In any other circumstance, this would result in a memory leak...So be conscious of that if this bug gets fixed in a newer version of the SDK.

#### Additional Details

There is a fun discussion about this in the [OpenTok Support Forums](https://support.tokbox.com/hc/en-us/community/posts/206712006-OpenTok-Crash-when-using-custom-OTVideoCapture-for-OTPublisherKit-) worth perusing. In short, the issue is actually that ARC sees the `initCapture` method on the class implementing `OTVideoCapture` as a `initializer`, and as such, is inserting a `release` without a corresponding `retain`. This is causing the reference count to get slightly out of whack, since it isn't actually an `initializer`.

I don't think this should actually be happening, because according to the [ARC docs](http://clang.llvm.org/docs/AutomaticReferenceCounting.html#method-families) for what defines an `init` method, they must _"must return an Objective-C pointer type"_, and the method certainly doesn't return one. However, [Swift initializers do not return a value](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html), which may be why ARC is treating the method this way.

Moral of the story: Don't use `init` in your method names, unless it is actually an `initializer`.

#### Test Version Details

These are the versions I used for my test, although other versions likely exhibit the same behavior.

* iOS: v9.3
* XCode: v7.3.1
* OpenTok SDK: v2.8.1
* CocoaPods: v1.0.0.rc.2

