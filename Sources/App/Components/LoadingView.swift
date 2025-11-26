import SwiftUI

/// Reusable loading view component
public struct LoadingView: View {
    let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(Color(red: 0.73, green: 0.33, blue: 0.83))

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Skeleton view for loading states
public struct SkeletonView: View {
    @State private var isAnimating = false
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .cornerRadius(cornerRadius)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(cornerRadius)
                    .offset(x: isAnimating ? 400 : -400)
                    .animation(
                        .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            )
            .onAppear {
                isAnimating = true
            }
    }
}

/// Skeleton list item
public struct SkeletonListItem: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 12) {
            SkeletonView()
                .frame(width: 50, height: 50)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(height: 16)

                SkeletonView()
                    .frame(height: 12)
                    .frame(maxWidth: 200)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

/// Skeleton card
public struct SkeletonCard: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(height: 24)
                .frame(maxWidth: 150)

            SkeletonView()
                .frame(height: 16)

            SkeletonView()
                .frame(height: 16)
                .frame(maxWidth: 200)

            HStack {
                SkeletonView()
                    .frame(width: 80, height: 32)
                    .cornerRadius(16)

                Spacer()

                SkeletonView()
                    .frame(width: 80, height: 32)
                    .cornerRadius(16)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

/// Pull to refresh modifier
public struct PullToRefreshModifier: ViewModifier {
    let onRefresh: () async -> Void
    @State private var isRefreshing = false

    public init(onRefresh: @escaping () async -> Void) {
        self.onRefresh = onRefresh
    }

    public func body(content: Content) -> some View {
        content
            .refreshable {
                guard !isRefreshing else { return }
                isRefreshing = true
                await onRefresh()
                isRefreshing = false
            }
    }
}

extension View {
    /// Add pull-to-refresh functionality
    public func pullToRefresh(onRefresh: @escaping () async -> Void) -> some View {
        modifier(PullToRefreshModifier(onRefresh: onRefresh))
    }
}

/// Loading state enum
public enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)

    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    public var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }

    public var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}
