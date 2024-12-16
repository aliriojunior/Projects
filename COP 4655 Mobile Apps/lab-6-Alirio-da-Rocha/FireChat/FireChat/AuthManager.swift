import Foundation
import FirebaseAuth // <-- Import Firebase Auth

@Observable
class AuthManager {
   
   var user: User?
   
   var isMocked: Bool = false
   
   var isSignedIn: Bool = false
   
   var userEmail: String? {
       
       isMocked ? "kingsley@dog.com" : user?.email
       
   }
   
   private var handle: AuthStateDidChangeListenerHandle?
   
   init() {
       handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
           self?.user = user
           self?.isSignedIn = user != nil
       }
   }
   
   deinit {
       if let handle = handle {
           Auth.auth().removeStateDidChangeListener(handle)
       }
   }
    init(isMocked: Bool = false) {

       self.isMocked = isMocked

       // TODO: Check for cached user for persisted login
    }

    // https://firebase.google.com/docs/auth/ios/start#sign_up_new_users
    func signUp(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                user = authResult.user // <-- Set the user
            } catch {
                print(error)
            }
        }

    }

    // https://firebase.google.com/docs/auth/ios/start#sign_in_existing_users
    func signIn(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                user = authResult.user // <-- Set the user
            } catch {
                print(error)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil // <-- Set user to nil after sign out
        } catch {
            print(error)
        }
    }
}
