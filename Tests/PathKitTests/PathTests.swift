/**
    PathTests.swift
    PathKitTests
 
    Created by Tibor Bödecs on 2019.02.27.
    Copyright Binary Birds. All rights reserved.
 */

import XCTest
@testable import PathKit

final class PathTests: XCTestCase {

    static var allTests = [
        ("testIsExistingDirectory", testIsExistingDirectory),
        ("testDirectoryStructure", testDirectoryStructure),
        ("testOperations", testOperations),
    ]
    
    func testIsExistingDirectory() {
        let invalid = Path("ZCQv1XRkC5BbwAmGW9pqLWnDCr3")
        XCTAssertFalse(invalid.isDirectory, "Directory should not exists")
    }
    
    func testDirectoryStructure() {
        let home = Path.home
        XCTAssertEqual(home.location, NSHomeDirectory(), "Invalid home directory path")

        var components = home.location.split(separator: "/")
        components.removeLast()
        let parentPath = "/" + components.joined(separator: "/")
        XCTAssertEqual(parentPath, home.parent.location, "Invalid parent directory path")
        
        let root = Path.root
        XCTAssertEqual(root.location, "/", "Invalid root directory path")
        
        XCTAssertFalse(root.isLink, "Root url should not be a link")
        
        let parent = root.parent
        XCTAssertEqual(parent.location, "/", "Invalid parent directory path")
        
        #if os(macOS)
        let user = Path(systemDirectory: .user)
        XCTAssertEqual(user.location, home.parent.location, "Invalid user directory path")
        #endif
    }
    
    func testOperations() throws {
        let current = Path.current
        //clean start
        try current.child("dir-test").delete()
        
        let test = try current.add("dir-test")
        XCTAssert(test.isDirectory, "Directory should exists")
        XCTAssert(test.children().isEmpty, "Directory should be empty")
        
        let permission = 0o755
        try test.chmod(permission)
        
        XCTAssertEqual(permission, test.permissions, "Invalid permissions")
        
        let a = try test.add("a")
        let b = test.child("b")
        let c = test.child("c")
        let d = test.child("d")
        let e = test.child("e")
        _ = try test.add(".h")

        try a.copy(to: b, force: true)
        XCTAssert(b.isDirectory, "Directory should exists")
        
        try a.link(to: c, force: true)
        XCTAssert(c.isDirectory, "Directory should exists")
        
        try d.create()
        XCTAssert(d.isDirectory, "Directory should exists")
        
        try a.move(to: e, force: true)
        XCTAssert(e.isDirectory, "Directory should exists")

        XCTAssert(!a.isDirectory, "Directory should NOT exists")

        let dirs = test.children().filter(\.isDirectory).filter(\.isVisible).map(\.name)
        XCTAssertEqual(Set(dirs), Set(["b", "d", "e"]), "Invalid directory structure")
        print(test.children())
        
        let files = test.children().filter(\.isLink).map(\.name)
        XCTAssertEqual(Set(files), Set(["c"]), "Invalid file structure")
        
        try b.delete()

        let remainingDirs = test.children().filter(\.isDirectory).map(\.name)
        XCTAssertEqual(Set(remainingDirs), Set(["d", "e", ".h"]), "Invalid directory structure")
    }
}
