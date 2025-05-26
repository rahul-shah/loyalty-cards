import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "creditcard.fill")
                    .resizable()
                    .frame(width: 80, height: 60)
                    .foregroundColor(.accentColor)
                
                Text("Loyalty Cards")
                    .font(.system(size: 36, weight: .bold))
                
                Text("Store all your loyalty cards in one place")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $authManager.isAuthenticated) {
            CardsListView()
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                // Store user identifier
                let userId = appleIDCredential.user
                UserDefaults.standard.set(userId, forKey: "appleUserIdentifier")
                
                // Store user name if provided
                if let fullName = appleIDCredential.fullName {
                    let userName = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    if !userName.isEmpty {
                        UserDefaults.standard.set(userName, forKey: "userName")
                    }
                }
                
                // Store email if provided
                if let email = appleIDCredential.email {
                    UserDefaults.standard.set(email, forKey: "userEmail")
                }
                
                // Set authentication state
                authManager.isAuthenticated = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }
    
    private init() {
        // Check if user was previously authenticated
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        
        // Check for existing Apple ID credential
        if let userIdentifier = UserDefaults.standard.string(forKey: "appleUserIdentifier") {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        self.isAuthenticated = true
                    case .revoked, .notFound:
                        self.isAuthenticated = false
                        UserDefaults.standard.removeObject(forKey: "appleUserIdentifier")
                        UserDefaults.standard.removeObject(forKey: "userName")
                        UserDefaults.standard.removeObject(forKey: "userEmail")
                    default:
                        break
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
} 
