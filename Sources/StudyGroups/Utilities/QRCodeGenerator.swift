import CoreImage
import Foundation

#if canImport(UIKit)
import UIKit

/// Utility for generating QR codes for study groups
public struct QRCodeGenerator {
    /// Generate a QR code image for a study group
    /// - Parameter groupId: The study group ID to encode
    /// - Returns: A UIImage containing the QR code, or nil if generation fails
    public static func generateQRCode(for groupId: String) -> UIImage? {
        // Create the data to encode
        let data = "studyhaven://group/\(groupId)".data(using: .utf8)
        
        // Create QR code filter
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let qrCodeImage = filter.outputImage else {
            return nil
        }
        
        // Scale up the image
        let scale = 10.0
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = qrCodeImage.transformed(by: transform)
        
        // Convert to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
#else
/// Stub for non-iOS platforms
public struct QRCodeGenerator {
    public static func generateQRCode(for groupId: String) -> Any? {
        return nil
    }
}
#endif
