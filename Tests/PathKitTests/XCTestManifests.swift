/**
    XCTestManifests.swift
    PathKitTests
 
    Created by Tibor Bödecs on 2019.02.27.
    Copyright Binary Birds. All rights reserved.
 */

import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PathTests.allTests),
    ]
}
#endif
