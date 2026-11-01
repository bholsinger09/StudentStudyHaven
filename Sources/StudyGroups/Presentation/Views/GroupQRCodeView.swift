import SwiftUI
import Core

#if canImport(UIKit)
import UIKit

/// View for displaying a study group's QR code for members to scan
public struct GroupQRCodeView: View {
    let group: StudyGroup
    @State private var qrCodeImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    public init(group: StudyGroup) {
        self.group = group
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Invite Members")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    Text("Share this QR code with others")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let image = qrCodeImage {
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    } else {
                        ProgressView()
                            .frame(height: 250)
                    }
                    
                    Text("They can scan this QR code to join \"\(group.name)\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Divider()
                
                VStack(spacing: 8) {
                    Text("Manual Join Code")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(group.id)
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        UIPasteboard.general.string = group.id
                    }) {
                        Label("Copy Code", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = QRCodeGenerator.generateQRCode(for: group.id)
            DispatchQueue.main.async {
                self.qrCodeImage = image
            }
        }
    }
}
#else
/// Stub for non-iOS platforms
public struct GroupQRCodeView: View {
    let group: StudyGroup
    
    public init(group: StudyGroup) {
        self.group = group
    }
    
    public var body: some View {
        Text("QR Code not available on this platform")
    }
}
#endif
