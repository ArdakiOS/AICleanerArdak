import SwiftUI
import GoogleSignIn


class EmailViewModel : ObservableObject {
    
    @Published var gAccount : GIDGoogleUser?
    
    init() {
        restoreUser()
    }
    
    func restoreUser() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            // Check if `user` exists; otherwise, do something with `error`
            self.gAccount = user
            
            
        }
    }
    
    func handleSignInButton() {
        GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.windows.first?.rootViewController ?? UIViewController(), hint: "", additionalScopes: ["https://mail.google.com/"]){ signInResult, error in
            guard let result = signInResult else {
                // Inspect error
                return
            }
            self.gAccount = result.user
            // If sign in succeeded, display the app's main content View.
        }
        
    }
    
    func loadMessages() {
        if gAccount != nil {
            print("Bearer \(gAccount!.accessToken.tokenString)")
            guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/labels") else {return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data,resp,error in
                guard let data = data, error == nil else {return}
                
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Raw Data: \(rawString)")
                } else {
                    print("Unable to convert data to string")
                }
            }
            
            task.resume()
        }
    }
}
