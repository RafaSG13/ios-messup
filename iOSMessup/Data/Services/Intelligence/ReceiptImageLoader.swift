//
//  ReceiptImageLoader.swift
//  iOSMessup
//

import CoreGraphics
import Foundation
import ImageIO

enum ReceiptImageLoader {
    /// Decodes `data` into an upright image whose longest side is at most `maxPixelSize`, so a full-resolution
    /// photo does not blow the model's context. `nil` when the data is not an image.
    static func cgImage(from data: Data, maxPixelSize: Int = 1600) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}
