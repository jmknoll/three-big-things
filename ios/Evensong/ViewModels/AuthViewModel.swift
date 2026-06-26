import Foundation
// import GoogleSignIn  // Commented out — re-enable when adding Google auth

private struct EmailSignUpRequest: Encodable {
    let email: String
    let password: String
    let name: String?
    let tzOffset: Int
}

private struct EmailSignInRequest: Encodable {
    let email: String
    let password: String
}

private struct OAuthRequest: Encodable {
    let token: String
    let tzOffset: Int
}

private struct AuthResponse: Decodable {
    let token: String
    let user: User
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: String?

    init() {
        Task { await tryRestoreSession() }
    }

    // MARK: - Email Auth

    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let body = EmailSignUpRequest(
                email: email,
                password: password,
                name: name.isEmpty ? nil : name,
                tzOffset: TimeZone.current.secondsFromGMT() / 60
            )
            let response: AuthResponse = try await APIClient.shared.request(.emailSignUp, body: body)
            try await TokenStore.shared.set(response.token)
            user = response.user
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let body = EmailSignInRequest(email: email, password: password)
            let response: AuthResponse = try await APIClient.shared.request(.emailSignIn, body: body)
            try await TokenStore.shared.set(response.token)
            user = response.user
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Password Reset & Email Confirmation

    func forgotPassword(email: String) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            struct Body: Encodable { let email: String }
            struct Response: Decodable { let message: String }
            let _: Response = try await APIClient.shared.request(.forgotPassword, body: Body(email: email))
            return true
        } catch {
            return true // Always true — don't reveal whether email exists
        }
    }

    func resendConfirmation(email: String) async {
        do {
            struct Body: Encodable { let email: String }
            struct Response: Decodable { let message: String }
            let _: Response = try await APIClient.shared.request(.resendConfirmation, body: Body(email: email))
        } catch {
            // Non-fatal
        }
    }

    // MARK: - Google Auth (commented out — re-enable when adding Google auth)

    /*
    func signInWithGoogle(presenting viewController: UIViewController) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            guard let idToken = result.user.idToken?.tokenString else {
                error = "Failed to get ID token from Google."
                return
            }
            let tzOffset = TimeZone.current.secondsFromGMT() / 60
            let body = OAuthRequest(token: idToken, tzOffset: tzOffset)
            let response: AuthResponse = try await APIClient.shared.request(.oauth, body: body)
            try await TokenStore.shared.set(response.token)
            user = response.user
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
    */

    // MARK: - Shared

    func refreshUser() async {
        do {
            let response: AuthResponse = try await APIClient.shared.request(.me)
            try await TokenStore.shared.set(response.token)
            user = response.user
        } catch APIError.unauthorized {
            signOut()
        } catch {
            // Non-fatal on background refresh
        }
    }

    func signOut() {
        // GIDSignIn.sharedInstance.signOut()  // Re-enable with Google auth
        Task { try? await TokenStore.shared.clear() }
        user = nil
    }

    // MARK: - Private

    private func tryRestoreSession() async {
        guard (try? await TokenStore.shared.get()) != nil else { return }
        await refreshUser()
    }
}
