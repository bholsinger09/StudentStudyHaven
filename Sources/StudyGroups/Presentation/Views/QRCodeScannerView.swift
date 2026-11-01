import SwiftUI
import AVFoundation

#if canImport(UIKit)
import UIKit

/// Coordinator for camera access and QR code scanning
public class QRScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    @Binding var scannedCode: String?
    @Binding var errorMessage: String?
    var captureSession: AVCaptureSession?
    
    public init(scannedCode: Binding<String?>, errorMessage: Binding<String?>) {
        self._scannedCode = scannedCode
        self._errorMessage = errorMessage
        super.init()
    }
    
    public func setupCamera() {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannedCode = nil
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            errorMessage = "Unable to access camera"
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            errorMessage = "Cannot add video input"
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            errorMessage = "Cannot add metadata output"
            return
        }
        
        self.captureSession = captureSession
    }
    
    public func startSession() {
        if let captureSession = captureSession, !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    public func stopSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let stringValue = metadataObject.stringValue {
            scannedCode = stringValue
            stopSession()
        }
    }
}

/// Controller for camera preview
public class QRScannerViewController: UIViewController {
    var coordinator: QRScannerCoordinator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let coordinator = coordinator else { return }
        coordinator.setupCamera()
        
        if let captureSession = coordinator.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            coordinator.startSession()
        }
    }
}

/// View for scanning QR codes
public struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var errorMessage: String?
    
    public init(scannedCode: Binding<String?>, errorMessage: Binding<String?>) {
        self._scannedCode = scannedCode
        self._errorMessage = errorMessage
    }
    
    public func makeCoordinator() -> QRScannerCoordinator {
        QRScannerCoordinator(scannedCode: $scannedCode, errorMessage: $errorMessage)
    }
    
    public func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.coordinator = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

/// Wrapper view for QR code scanner
public struct QRCodeScannerWrapper: View {
    @State private var scannedCode: String?
    @State private var errorMessage: String?
    let onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(onScan: @escaping (String) -> Void) {
        self.onScan = onScan
    }
    
    public var body: some View {
        ZStack {
            QRScannerView(scannedCode: $scannedCode, errorMessage: $errorMessage)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Point camera at QR code")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("The QR code will be automatically scanned")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .onChange(of: scannedCode) { newCode in
            if let code = newCode {
                onScan(code)
                dismiss()
            }
        }
        .alert("Camera Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { dismiss() }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
}
#else
/// Stub for non-iOS platforms
public struct QRScannerView: View {
    public var body: some View {
        Text("QR Scanner not available on this platform")
    }
}

/// Stub for non-iOS platforms
public struct QRCodeScannerWrapper: View {
    let onScan: (String) -> Void
    
    public init(onScan: @escaping (String) -> Void) {
        self.onScan = onScan
    }
    
    public var body: some View {
        Text("QR Scanner not available on this platform")
    }
}
#endif
