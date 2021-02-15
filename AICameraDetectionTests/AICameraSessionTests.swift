//
//  AICameraDetectionTests.swift
//  AICameraDetectionTests
//
//  Created by Азиз on 06.02.2021.
//

import XCTest

class AICameraSessionTests: XCTestCase {

    func testCameraSession_is_inited() {
        // given
        let session = AISessionManager(cameraView: UIView())
        // then
        XCTAssertNotNil(session)
    }

    func testSession_start_detectionType_is_face() {
        let session = AISessionManager(cameraView: UIView())
        let type = AIDetectionType.face

        XCTAssertEqual(type, session.detectionType)
    }

}
