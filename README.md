# PathKit (💾)

Working with files and directories in a nice way using Swift.

## Usage

Some examples:

```swift
import PathKit

let caches = Path.systemDirectory(for: .caches)
let home = Path.home
let parent = home.parent
let root = Path.root
let current = Path.current
let test = current.child("test")

print(test.isDirectory)
print(test.children().filter(\.isFile))

do {
    let work = try home.add("my-work-dir")
    print(work.location)

    try test.delete()
    try test.create()
    
    let a = current.child("a")
    try a.create()
    
    let b = current.child("b")
    let c = current.child("c")
    let d = current.child("d")

    try a.copy(to: b)
    try a.link(to: c)
    try a.move(to: d, force: true)
}
catch {
    print(error.localizedDescription)
}
```



## Install

Just use the Swift Package Manager as usual:

```swift
.package(url: "https://github.com/binarybirds/path-kit", from: "1.0.0"),
```

Don't forget to add "PathKit" to your target as a dependency!

```swift
.product(name: "PathKit", package: "path-kit"),
```

That's it.


## License

[WTFPL](LICENSE) - Do what the fuck you want to.
