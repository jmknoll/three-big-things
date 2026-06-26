import SwiftUI

enum AuthMode {
    case signIn, signUp
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var mode: AuthMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @FocusState private var focusedField: LoginField?
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var forgotPasswordSent = false

    private enum LoginField { case name, email, password }

    private var canSubmit: Bool {
        let emailOk = email.contains("@") && email.contains(".")
        let passwordOk = password.count >= 6
        let nameOk = mode == .signIn || !name.trimmingCharacters(in: .whitespaces).isEmpty
        return emailOk && passwordOk && nameOk && !auth.isLoading
    }

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: Space.sm) {
                        Text("Evensong")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.ink)
                        Text("A daily practice of focused, purposeful progress.")
                            .font(.body)
                            .foregroundStyle(Color.stone)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Space.xl3)
                    }
                    .padding(.top, Space.xl4)
                    .padding(.bottom, Space.xl3)

                    // Mode picker
                    HStack(spacing: 0) {
                        modeTab("Sign in", selected: mode == .signIn) { mode = .signIn }
                        modeTab("Create account", selected: mode == .signUp) { mode = .signUp }
                    }
                    .padding(.horizontal, Space.xl)
                    .padding(.bottom, Space.xl2)

                    // Form
                    VStack(spacing: Space.md) {
                        if mode == .signUp {
                            inputField(
                                placeholder: "Your name",
                                text: $name,
                                field: .name,
                                contentType: .name,
                                capitalization: .words
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        inputField(
                            placeholder: "Email",
                            text: $email,
                            field: .email,
                            contentType: .emailAddress,
                            keyboardType: .emailAddress
                        )

                        inputField(
                            placeholder: "Password\(mode == .signUp ? " (min. 6 characters)" : "")",
                            text: $password,
                            field: .password,
                            contentType: mode == .signUp ? .newPassword : .password,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, Space.xl)
                    .animation(.standard, value: mode)

                    if let error = auth.error {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.amber)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Space.xl)
                            .padding(.top, Space.md)
                            .transition(.opacity)
                    }

                    CTAButton(
                        title: mode == .signIn ? "Sign in" : "Create account",
                        isEnabled: canSubmit
                    ) {
                        await submit()
                    }
                    .padding(.horizontal, Space.xl)
                    .padding(.top, Space.xl2)

                    if mode == .signIn {
                        Button("Forgot password?") {
                            forgotPasswordEmail = email
                            forgotPasswordSent = false
                            showForgotPassword = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.indigo)
                        .padding(.top, Space.md)
                    }

                    // Google auth placeholder (commented out — re-enable later)
                    /*
                    Button("Continue with Google") {
                        Task { await signInWithGoogle() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.indigo)
                    .padding(.top, Space.md)
                    */
                }
            }
            .scrollDismissesKeyboard(.interactively)

            if auth.isLoading {
                Color.black.opacity(0.1).ignoresSafeArea()
                    .allowsHitTesting(true)
                ProgressView()
            }
        }
        .onChange(of: mode) { _, _ in
            auth.error = nil
            focusedField = mode == .signUp ? .name : .email
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordSheet(
                email: $forgotPasswordEmail,
                sent: $forgotPasswordSent,
                onSubmit: { emailToReset in
                    await auth.forgotPassword(email: emailToReset)
                    forgotPasswordSent = true
                }
            )
            .presentationDetents([.height(320)])
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func modeTab(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.callout.weight(selected ? .semibold : .regular))
                .foregroundStyle(selected ? Color.ink : Color.stone)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.sm)
                .background(
                    selected
                        ? Color.surface
                        : Color.clear
                )
                .cornerRadius(8)
        }
        .animation(.standard, value: selected)
    }

    @ViewBuilder
    private func inputField(
        placeholder: String,
        text: Binding<String>,
        field: LoginField,
        contentType: UITextContentType,
        keyboardType: UIKeyboardType = .default,
        capitalization: TextInputAutocapitalization = .never,
        isSecure: Bool = false
    ) -> some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(capitalization)
            }
        }
        .textContentType(contentType)
        .autocorrectionDisabled()
        .focused($focusedField, equals: field)
        .font(.body)
        .foregroundStyle(Color.ink)
        .padding(Space.md)
        .background(Color.surface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(focusedField == field ? Color.indigo.opacity(0.5) : Color.mist, lineWidth: 1)
        )
        .onSubmit { advanceFocus(from: field) }
    }

    // MARK: - Actions

    private func submit() async {
        focusedField = nil
        if mode == .signIn {
            await auth.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
        } else {
            await auth.signUp(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                name: name.trimmingCharacters(in: .whitespaces)
            )
        }
    }

    private func advanceFocus(from field: LoginField) {
        switch (mode, field) {
        case (.signUp, .name):    focusedField = .email
        case (_, .email):         focusedField = .password
        case (_, .password):      Task { await submit() }
        default:                  break
        }
    }
}

// MARK: - Forgot Password Sheet

struct ForgotPasswordSheet: View {
    @Binding var email: String
    @Binding var sent: Bool
    let onSubmit: (String) async -> Void
    @Environment(\.dismiss) private var dismiss

    private var canSubmit: Bool {
        email.contains("@") && email.contains(".")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.xs) {
                Text(sent ? "Check your inbox" : "Reset password")
                    .font(.title2.bold())
                    .foregroundStyle(Color.ink)
                Text(sent
                     ? "If an account exists for \(email), a reset link is on its way."
                     : "Enter your email and we'll send you a reset link.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stone)
            }

            if !sent {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .font(.body)
                    .foregroundStyle(Color.ink)
                    .padding(Space.md)
                    .background(Color.surface)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.mist, lineWidth: 1)
                    )

                CTAButton(title: "Send reset link", isEnabled: canSubmit) {
                    await onSubmit(email.trimmingCharacters(in: .whitespaces))
                }
            } else {
                Button("Done") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.sage)
                    .foregroundStyle(.white)
                    .font(.body.weight(.semibold))
                    .cornerRadius(10)
            }
        }
        .padding(Space.xl)
        .animation(.standard, value: sent)
    }
}
