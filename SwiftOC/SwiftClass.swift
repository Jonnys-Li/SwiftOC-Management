import Foundation

@objc class SwiftClass: NSObject {

    let name: String

    @objc init(name: String) {
        self.name = name
    }

    @objc func greeting() -> String {
        return "Hello from Swift, \(name)!"
    }

    @objc static func callOC() -> String {
        let oc = OCClass(name: "Swift")
        return oc.greeting()
    }
}
