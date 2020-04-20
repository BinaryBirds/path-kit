/**
    PathKit.swift
    PathKit
 
    Created by Tibor Bödecs on 2019.02.27.
    Copyright Binary Birds. All rights reserved.
 */

import Foundation

// a custom file node representation object
public struct Path {
    
    public static let separator = "/"
    
    // Available directory paths
    public enum SystemDirectory: CaseIterable {
        case application
        case demoApplication
        case developerApplication
        case adminApplication
        case library
        case developer
        case user
        case documentation
        case document
        case coreService
        case autosavedInformation
        case desktop
        case caches
        case applicationSupport
        case downloads
        case inputMethods
        case movies
        case music
        case pictures
        case printerDescription
        case sharedPublic
        case preferencePanes
        case applicationScripts
        case itemReplacement
        case allApplications
        case allLibraries
        case trash

        // underlying file manager search path directory
        fileprivate var searchPathDirectory: FileManager.SearchPathDirectory {
            switch self {
            case .application:
                return .applicationDirectory
            case .demoApplication:
                return .demoApplicationDirectory
            case .developerApplication:
                return .developerApplicationDirectory
            case .adminApplication:
                return .adminApplicationDirectory
            case .library:
                return .libraryDirectory
            case .developer:
                return .developerDirectory
            case .user:
                return .userDirectory
            case .documentation:
                return .documentationDirectory
            case .document:
                return .documentDirectory
            case .coreService:
                return .coreServiceDirectory
            case .autosavedInformation:
                return .autosavedInformationDirectory
            case .desktop:
                return .desktopDirectory
            case .caches:
                return .cachesDirectory
            case .applicationSupport:
                return .applicationSupportDirectory
            case .downloads:
                return .downloadsDirectory
            case .inputMethods:
                return .inputMethodsDirectory
            case .movies:
                return .moviesDirectory
            case .music:
                return .musicDirectory
            case .pictures:
                return .picturesDirectory
            case .printerDescription:
                return .printerDescriptionDirectory
            case .sharedPublic:
                return .sharedPublicDirectory
            case .preferencePanes:
                return .preferencePanesDirectory
            case .applicationScripts:
                return .applicationScriptsDirectory
            case .itemReplacement:
                return .itemReplacementDirectory
            case .allApplications:
                return .allApplicationsDirectory
            case .allLibraries:
                return .allLibrariesDirectory
            case .trash:
                return .trashDirectory
            }
        }
    }
    
    // MARK: - properties

    // the path of the current directory
    private var currentPath: String
    
    // FileManager instance used to perform operations
    public var fileManager: FileManager = .default

    // init with a new path
    public init(_ path: String) {
        self.currentPath = path
    }

    // init with a new URL
    public init(_ url: URL) {
        self.currentPath = url.path
    }

    /**
       init with a system directory
    
       NOTE: only works on Apple platforms, it'll always return the home directory on any other operating system
    */
    public init(systemDirectory: SystemDirectory) {
        self.currentPath = "~"
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        if let path =  NSSearchPathForDirectoriesInDomains(systemDirectory.searchPathDirectory, .allDomainsMask, true).first {
            self.currentPath = path
        }
        #endif
    }

    // MARK: - static
    
    //returns the home path
    public static var home: Self { .init("~") }

    // returns the root path
    public static var root: Self { .init(Path.separator) }
    
    // returns the current path
    public static var current: Self { .init(FileManager.default.currentDirectoryPath) }

    // MARK: - api

    public var location: String {
        NSString(string: self.currentPath).standardizingPath 
    }
    
    // returns a file url with the path
    public var url: URL {
        .init(fileURLWithPath: self.location)
    }
    
    // returns the parent directory
    public var parent: Self {
        return .init(self.url.deletingLastPathComponent().path)
    }
    
    // returns the child directory representation
    public func child(_ path: String) -> Self {
        .init(self.currentPath + Path.separator + path)
    }

    // checks if the path is absolute
    public var isAbsolute: Bool {
        self.currentPath.hasPrefix(Path.separator)
    }

    // checks if the path is relative
    public var isRelative: Bool {
        !self.isAbsolute
    }

    // returns the file name
    public var name: String {
        if self.extension != nil {
            return self.url.deletingLastPathComponent().lastPathComponent
        }
        return self.url.lastPathComponent
    }

    // returns the file extension
    public var `extension`: String? {
        let ext = self.url.pathExtension
        guard !ext.isEmpty else {
            return nil
        }
        return ext
    }
    
    // checks if the file node is hidden
    public var isHidden: Bool {
        self.url.lastPathComponent.hasPrefix(".")
    }

    // checks if the node is visible
    public var isVisible: Bool {
        !self.isHidden
    }
    
    // checks if a node exists
    public var exists: Bool {
        self.fileManager.fileExists(atPath: self.currentPath)
    }
    
    // checks if a file exists and is a file
    public var isFile: Bool {
        self.exists && !self.isDirectory && !self.isLink
    }

    // checks if a file exists and it is a directory
    public var isDirectory: Bool {
        var isDir = ObjCBool(false)
        if self.fileManager.fileExists(atPath: self.currentPath, isDirectory: &isDir) {
            return isDir.boolValue
        }
        return false
    }

    // checks if resource is a link
    public var isLink: Bool {
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        let resourceValues = try! self.url.resourceValues(forKeys: [.isSymbolicLinkKey])
        if let isSymbolicLink = resourceValues.isSymbolicLink {
            return isSymbolicLink
        }
        #endif
        return false
    }

    // returns the original url of a symlink
    public var linkPath: Path? {
        guard self.isLink else {
            return nil
        }
        return Path(self.url.resolvingSymlinksInPath())
    }

    // MARK: - children
    
    public func children() -> [Path] {
        guard self.isDirectory else {
            return []
        }
        let list = try? self.fileManager.contentsOfDirectory(at: self.url,
                                                              includingPropertiesForKeys: nil,
                                                              options: [])

        return list?.map { Path($0.path) } ?? []
    }

    // MARK: - fileManager api
    
    /**
        Add a new directory under the current one
     
        - Parameters:
            - path: Creates every component in the path
            - isHidden: Appends a . prefix if it's true (default false)
        - Throws:
            FileManager error if directory could not be created
     
        - Returns: New instance
     */
    public func add(_ path: String) throws -> Self {
        let path = self.child(path)
        try path.create()
        return path
    }

    /**
        Creates the directory
     
        - Parameters:
            - withIntermediateDirectories: Creates every component in the path
            - attributes: Additional file attributes
     
        - Throws:
            FileManager error if directory could not be created
     */
    public func create(withIntermediateDirectories: Bool = true,
                       attributes: [FileAttributeKey : Any]? = nil) throws {
        guard !self.isDirectory else {
            return
        }
        try self.fileManager.createDirectory(atPath: self.currentPath,
                                             withIntermediateDirectories: withIntermediateDirectories,
                                             attributes: attributes)
    }

    /**
        Removes the current directory
     
        - Throws:
            FileManager error if directory could not be removed
     */
    public func delete() throws {
        guard self.exists else {
            return
        }
        try self.fileManager.removeItem(at: self.url)
    }
    
    /**
        Copies the current directory to a new location
     
        - Parameters:
            - to: The location of the copy
            - force: If a file exists at the destination it'll be removed first
     
        - Throws:
            FileManager error if directory could not be copied
     */
    public func copy(to destination: Path, force: Bool = false) throws {
        if force, destination.exists {
            try destination.delete()
        }
        try self.fileManager.copyItem(at: self.url, to: destination.url)
    }

    /**
        Moves the current directory to a new location
     
        - Parameters:
            - to: The location of the moved directory
            - force: If a file exists at the destination it'll be removed first
     
        - Throws:
            FileManager error if directory could not be moved
     */
    public func move(to destination: Path, force: Bool = false) throws {
        if force, destination.exists {
            try destination.delete()
        }
        try self.fileManager.moveItem(at: self.url, to: destination.url)
    }

    /**
        Symlink the current directory to a given location
     
        - Parameters:
            - to: The location of the symlink
            - force: If a file exists at the destination it'll be removed first
     
        - Throws:
            FileManager error if directory could not be linked
     */
    public func link(to destination: Path, force: Bool = false) throws {
        if force, destination.exists {
            try destination.delete()
        }
        try self.fileManager.createSymbolicLink(at: destination.url, withDestinationURL: self.url)
    }
    
    /**
        Change permissions of the current directory
     
        Conversion decimal - octal:
        ```
         let octal = 755
         if let decimal = Int(String(octal), radix: 8) {
             print(decimal)
         }
     
         let decimal = 493
         if let octal = Int(String(decimal, radix: 8)) {
             print(octal)
         }
        ```
     
        - Parameters:
            - permission: Permission like 0o755

        - Throws:
            FileManager error if directory could not be linked
     */
    public func chmod(_ permission: Int) throws {
        try self.fileManager.setAttributes([.posixPermissions: permission], ofItemAtPath: self.currentPath)
    }
    
    // returns posix permissions
    public var permissions: Int {
        let attributes = try! self.fileManager.attributesOfItem(atPath: self.currentPath)
        return attributes[.posixPermissions] as! Int
    }
}
