import SwiftUI
import GoogleSignIn


class EmailViewModel : ObservableObject {
    
    @Published var gAccount : GIDGoogleUser?
    @Published var foldersIds : [LabelModel] = []
    @Published var selectedFolderToDelete : [LabelModel] = []
    @Published var foldersToDisplay : [LabelModel] = []
    
    @Published var messagesIds : [Messages] = []
    
    @Published var selectedFolder : LabelModel?
    
    @Published var messagesToDisplay : [MessagesToDisplay] = []
    @Published var selectedMesagesToDelete : [MessagesToDisplay] = []
    
    @Published var nextPageToken = ""
    
    
    
    init() {
        restoreUser()
    }
    
    func restoreUser() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            // Check if `user` exists; otherwise, do something with `error`
            self.gAccount = user
            self.loadFolders()
            
            
        }
    }
    
    func handleSignInButton() {
        GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.windows.first?.rootViewController ?? UIViewController(), hint: "", additionalScopes: ["https://mail.google.com/"]){ signInResult, error in
            guard let result = signInResult else {
                // Inspect error
                return
            }
            self.gAccount = result.user
            self.loadFolders()
            // If sign in succeeded, display the app's main content View.
        }
        
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        gAccount = nil
        foldersIds = []
        selectedFolderToDelete = []
        foldersToDisplay = []
        messagesIds = []
        selectedFolder = nil
        messagesToDisplay = []
        selectedMesagesToDelete = []
        
    }
    
    func loadFolders() {
        if gAccount != nil {
            print("Bearer \(gAccount!.accessToken.tokenString)")
            guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/labels") else {return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) {data,resp,error in
                guard let data = data, error == nil else {return}
                
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(EmailFolderResponseModel.self, from: data)
                    DispatchQueue.main.async {
                        self.foldersIds = decodedData.labels
                        self.getFolderDetails()
                    }
                }
                catch {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    func getFolderDetails() {
        if !foldersIds.isEmpty {
            print("Bearer \(gAccount!.accessToken.tokenString)")
            var temp : [LabelModel] = []
            for folder in foldersIds {
                guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/labels/\(folder.id)") else {return }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) {data,resp,error in
                    guard let data = data, error == nil else {return}
                    
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(LabelModel.self, from: data)
                        DispatchQueue.main.async {
                            self.foldersToDisplay.append(decodedData)
                            self.foldersToDisplay = self.foldersToDisplay.sorted(by: {$0.messagesTotal ?? 0 > $1.messagesTotal ?? 0})
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                task.resume()
            }
            
            
            
        }
    }
    
    func getFolderMessages() {
        guard let id = selectedFolder?.id else {return}
        var urlStr = ""
        if !nextPageToken.isEmpty{
            urlStr = "https://gmail.googleapis.com/gmail/v1/users/me/messages?labelIds=\(id)&maxResults=20&pageToken=\(nextPageToken)"
        } else {
            urlStr = "https://gmail.googleapis.com/gmail/v1/users/me/messages?labelIds=\(id)&maxResults=20"
        }
        
        guard let url = URL(string: urlStr) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {data,resp,error in
            guard let data = data, error == nil else {return}
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(FolderMessagesResponse.self, from: data)
                DispatchQueue.main.async {
                    self.messagesIds = decodedData.messages
                    self.nextPageToken = decodedData.nextPageToken
                    self.getMessageDetails()
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getMessageDetails() {
        if !messagesIds.isEmpty {
            for msg in messagesIds {
                guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(msg.id)") else {return}
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) {data,resp,error in
                    guard let data = data, error == nil else {return}
                    
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(MessagesDetailedResponse.self, from: data)
                        var temp = MessagesToDisplay(id: decodedData.id, title: "", text: "", date: self.convertTimeIntervalToDateString(Double(decodedData.internalDate) ?? 0))
                        for header in decodedData.payload.headers {
                            if header.name == "From"{
                                if let res = header.value.unescapingUnicodeCharacters.components(separatedBy: "<").first{
                                    temp.title = res
                                } else {
                                    temp.title = header.value.unescapingUnicodeCharacters
                                }
                            }
                            else if header.name == "Subject"{
                                temp.text = header.value
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.messagesToDisplay.append(temp)
                        }
                    }
                    catch {
                        if let rawJSONString = String(data: data, encoding: .utf8) {
                            print("Raw JSON:")
                            print(rawJSONString)
                        } else {
                            print("Unable to convert data to string.")
                        }
                        print("ERROR GET MESSAGE DETAILS\(error)\n\n")
                    }
                }
                task.resume()
            }
        }
    }
    
    private func convertTimeIntervalToDateString(_ timeInterval: TimeInterval) -> String {
        // Convert milliseconds to seconds
        let seconds = timeInterval / 1000
        
        // Create a Date from the time interval
        let date = Date(timeIntervalSince1970: seconds)
        
        // Format the date to "MM/dd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        return dateFormatter.string(from: date)
    }
}


//{
//    "name": "Date",
//    "value": "Fri, 19 Jul 2024 03:32:51 +0000"
//},
//{
//    "name": "From",
//    "value": "\"Твиттер\" \u003cinfo@twitter.com\u003e"
//},
//{
//    "name": "To",
//    "value": "Ardak Ardak \u003cluxr2ge@gmail.com\u003e"
//},
//{
//    "name": "Subject",
//    "value": "Opera GX твитнул(а): no more."
//}
