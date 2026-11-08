import SwiftUI
import AVFoundation

#if canImport(UIKit)
import UIKit

/// Coordinator for camera access and QR code scanning
public class QRScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    @Binding var scannedCode: String?
    @Binding var errorMessage: String?
    var captureSession: AVCaptureSession?
    private var lastScannedCode: String? = nil
    
    public init(scannedCode: Binding<String?>, errorMessage: Binding<String?>) {
        self._scannedCode = scannedCode
        self._errorMessage = errorMessage
        super.init()
    }
    
    public func setupCamera() {
        let captureSession = AVCaptureSession()
        print("🎥 QRScannerCoordinator.setupCamera() - Starting camera setup")
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ QRScannerCoordinator: No video device available")
            DispatchQueue.main.async {
                self.scannedCode = nil
            }
            return
        }
        print("✅ QRScannerCoordinator: Video device found - \(videoCaptureDevice.localizedName)")
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("❌ QRScannerCoordinator: Failed to create video input - \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Unable to access camera"
            }
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            print("✅ QRScannerCoordinator: Video input added")
        } else {
            print("❌ QRScannerCoordinator: Cannot add video input")
            DispatchQueue.main.async {
                self.errorMessage = "Cannot add video input"
            }
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            print("✅ QRScannerCoordinator: Metadata output added with QR type")
        } else {
            print("❌ QRScannerCoordinator: Cannot add metadata output")
            DispatchQueue.main.async {
                self.errorMessage = "Cannot add metadata output"
            }
            return
        }
        
        self.captureSession = captureSession
        print("✅ QRScannerCoordinator: Setup complete")
    }
    
    public func startSession() {
        if let captureSession = captureSession, !captureSession.isRunning {
            print("🎥 QRScannerCoordinator: Starting capture session")
            lastScannedCode = nil
            captureSession.startRunning()
            print("✅ QRScannerCoordinator: Capture session running = \(captureSession.isRunning)")
        } else if captureSession != nil {
            print("⚠️ QRScannerCoordinator: Session already running")
        } else {
            print("❌ QRScannerCoordinator: No capture session to start")
        }
    }
    
    public func stopSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            print("🎥 QRScannerCoordinator: Stopping capture session")
            captureSession.stopRunning()
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let stringValue = metadataObject.stringValue {
            // Only process if this is a different code than the last one
            if stringValue != lastScannedCode {
                print("🎉 QRScannerCoordinator: QR code detected! Value: \(stringValue)")
                lastScannedCode = stringValue
                DispatchQueue.main.async {
                    self.scannedCode = stringValue
                    self.stopSession()
                }
            }
        }
    }
}

/// Controller for camera preview
public class QRScannerViewController: UIViewController {
    var coordinator: QRScannerCoordinator?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        print("🎥 QRScannerViewController.viewDidLoad() - Starting camera setup")
        
        // Request camera permission first
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("✅ QRScannerViewController: Camera permission granted")
                    self?.setupCameraSession()
                } else {
                    print("❌ QRScannerViewController: Camera permission denied")
                    self?.coordinator?.errorMessage = "Camera permission is required to scan QR codes"
                }
            }
        }
    }
    
    private func setupCameraSession() {
        guard let coordinator = coordinator else {
            print("❌ QRScannerViewController: No coordinator available")
            return
        }
        coordinator.setupCamera()
        
        if let captureSession = coordinator.captureSession {
            print("✅ QRScannerViewController: Capture session created, isRunning=\(captureSession.isRunning)")
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            
            if let layer = previewLayer {
                view.layer.addSublayer(layer)
                print("✅ QRScannerViewController: Preview layer added with frame \(layer.frame)")
            }
            
            coordinator.startSession()
            print("✅ QRScannerViewController: Capture session started, isRunning=\(captureSession.isRunning)")
        } else {
            print("❌ QRScannerViewController: No capture session available")
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layer = previewLayer, layer.frame != view.bounds {
            print("🎥 QRScannerViewController.viewDidLayoutSubviews() - Updating frame from \(layer.frame) to \(view.bounds)")
            layer.frame = view.bounds
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
    @State private var isProcessing = false
    let onScan: (String) -> Void
    let onScanComplete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    public init(onScan: @escaping (String) -> Void, onScanComplete: (() -> Void)? = nil) {
        self.onScan = onScan
        self.onScanComplete = onScanComplete
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
                
                if isProcessing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("Processing QR code...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .padding()
                } else {
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
                }
                
                Spacer()
            }
            .padding()
        }
        .onChange(of: scannedCode) { newCode in
            if let code = newCode {
                isProcessing = true
                onScan(code)
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
    let onScanComplete: (() -> Void)?
    
    public init(onScan: @escaping (String) -> Void, onScanComplete: (() -> Void)? = nil) {
        self.onScan = onScan
        self.onScanComplete = onScanComplete
    }
    
    public var body: some View {
        Text("QR Scanner not available on this platform")
    }
}
#endif
