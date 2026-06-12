import Foundation

extension Data {

    init(url: URL) throws {
        // init(contentsOf:) is broken in Swift 5.10 on Windows
        #if os(Windows) && swift(>=5.10)
        let input = InputStream(url: url)!
        try self.init(reading: input)
        #else
        try self.init(contentsOf: url)
        #endif
    }

    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }

}