//
//  OpenTokVideoCapturer.swift
//  OpenTok-Crash-Test
//
//  Created by Daniel Burgess on 5/11/16.
//  Copyright © 2016 Fitnet. All rights reserved.
//

import Foundation
import OpenTok

/**
 Custom implementation of `OTVideoCapture` protocol to hook up
 our own frame provider to OpenTok as a video capture device.
 */
class OpenTokVideoCapturer: NSObject, OTVideoCapture {

    /// The consumer for our video frames.
    weak var videoCaptureConsumer: OTVideoCaptureConsumer?

    /// Whether or not we are currently capturing for OpenTok.
    private var isCapturing: Bool = false

    func initCapture() {
        print("OpenTokVideoCapturer.initCapture()")
        // Do nothing.
    }

    func releaseCapture() {
        print("OpenTokVideoCapturer.releaseCapture")
        // Do nothing.
    }

    func startCapture() -> Int32 {
        print("OpenTokVideoCapturer.startCapture")
        isCapturing = true
        return 0
    }

    func stopCapture() -> Int32 {
        print("OpenTokVideoCapturer.stopCapture")
        isCapturing = false
        return 0
    }

    func isCaptureStarted() -> Bool {
        print("OpenTokVideoCapturer.isCaptureStarted() -> \(self.isCapturing)")
        return isCapturing
    }

    func captureSettings(videoFormat: OTVideoFormat!) -> Int32 {
        print("OpenTokVideoCapturer.captureSettings()")
        // We can't adjust the format, sorry.
        return 0
    }

    deinit {
        print("Bye, felicia.")
    }
}
