//
//  TokViewController.swift
//  OpenTok-Crash-Test
//
//  Created by Daniel Burgess on 5/11/16.
//  Copyright © 2016 Fitnet. All rights reserved.
//

import UIKit
import OpenTok

class TokViewController: UIViewController {

    /// The OpenTok Session.
    var session: OTSession? = nil

    /// The OpenTok Publisher.
    var publisher: OTPublisherKit? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // If we are connecting, but don't have a session yet, create one.
        if session == nil {
            createSession(
                sid: "SESSION_ID_HERE",
                tkn: "TOKEN_HERE"
            )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Helper method to create an OpenTok session with the given id.
     */
    private func createSession(sid sid: String, tkn: String) {
        // Create the OpenTok session.
        session = OTSession(
            apiKey: "API_KEY_HERE",
            sessionId: sid,
            delegate: self
        )

        var error: OTError?

        // Try to connect to the session.
        session?.connectWithToken(tkn, error: &error)

        // Check for errors.
        if let error = error {
            print("Error while connecting: \(error.localizedDescription)")
        }
    }

    /**
     Helper method to create an OpenTok publisher.
     */
    private func createPublisher() {
        // Create the publisher.
        publisher = OTPublisherKit(delegate: self)

        // Setup the custom video capturer.
        let videoCapture = OpenTokVideoCapturer()

        // Attach the video capture device to the publisher.
        publisher?.videoCapture = videoCapture

        var error: OTError?

        // Publish this stream to the session.
        session?.publish(publisher, error: &error)

        // Check for errors.
        if let error = error {
            print("Error while publishing to session: \(error.localizedDescription)")
        }
        print("Bye, scope.")
    }
}

// MARK: - OTSessionDelegate Methods

extension TokViewController: OTSessionDelegate {

    func sessionDidConnect(session: OTSession!) {
        print("sessionDidConnect")
        // Also create a publisher if we don't have one yet.
        if publisher == nil {
            createPublisher()
            print("Publisher created.")
        }
    }

    func sessionDidDisconnect(session: OTSession!) {
        print("sessionDidDisconnect")
    }

    func session(session: OTSession!, didFailWithError error: OTError!) {
        print("session.didFailWithError")
    }

    func session(session: OTSession!, streamCreated stream: OTStream!) {
        print("session.streamCreated")
    }

    func session(session: OTSession!, streamDestroyed stream: OTStream!) {
        print("session.streamDestroyed")
    }

    func session(session: OTSession!, connectionCreated connection: OTConnection!) {
        print("session.connectionCreated")
    }

    func session(session: OTSession!, connectionDestroyed connection: OTConnection!) {
        print("session.connectionDestroyed")
    }

    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        print("session.receivedSignalType")
    }

    func sessionDidBeginReconnecting(session: OTSession!) {
        print("sessionDidBeginReconnecting")
    }

    func sessionDidReconnect(session: OTSession!) {
        print("sessionDidReconnect")
    }
}

// MARK: - OTPublisherDelegate Methods

extension TokViewController: OTPublisherDelegate {

    func publisher(publisher: OTPublisherKit!, streamCreated stream: OTStream!) {
        print("publisher.streamCreated")
    }

    func publisher(publisher: OTPublisherKit!, didFailWithError error: OTError!) {
        print("publisher.didFailWithError")
    }

    func publisher(publisher: OTPublisherKit!, streamDestroyed stream: OTStream!) {
        print("publisher.streamDestroyed")
    }

    func publisher(publisher: OTPublisher!, didChangeCameraPosition position: AVCaptureDevicePosition) {
        print("publisher.didChangeCameraPosition")
    }
}
