import SwiftUI
import GoogleSignIn


class EmailViewModel : ObservableObject {
    
    @Published var gAccount : GIDGoogleUser?
    @Published var foldersIds : [LabelModel] = []
    @Published var selectedFolderToDelete : LabelModel?
    @Published var foldersToDisplay : [LabelModel] = []
    
    @Published var messagesIds : [Messages] = []
    
    @Published var selectedFolder : LabelModel?
    
    @Published var messagesToDisplay : [MessagesToDisplay] = []
    @Published var selectedMesagesToDelete : [MessagesToDisplay] = []
    
    @Published var nextPageToken : String?
    
    
    
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
        selectedFolderToDelete = nil
        foldersToDisplay = []
        messagesIds = []
        selectedFolder = nil
        messagesToDisplay = []
        selectedMesagesToDelete = []
        
    }
    
    func loadFolders() {
        if gAccount != nil {
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
            foldersToDisplay = []
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
                            self.selectedFolderToDelete = nil
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
        if let token = nextPageToken{
            if !token.isEmpty{
                urlStr = "https://gmail.googleapis.com/gmail/v1/users/me/messages?labelIds=\(id)&maxResults=20&pageToken=\(token)"
            } else {
                urlStr = "https://gmail.googleapis.com/gmail/v1/users/me/messages?labelIds=\(id)&maxResults=20"
            }
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
    
    func deleteMessages() {
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/batchDelete") else {return}
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = DeleteMessagesRequest(ids: selectedMesagesToDelete.map { $0.id }) // Directly map ids
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(body)
            if let jsonString = String(data: encodedData, encoding: .utf8) {
//                print("Request Body JSON:\n\(jsonString)\n")
            }
            request.httpBody = encodedData
        } catch {
            print(error)
        }
        
        let task = URLSession.shared.dataTask(with: request) {data, resp, error in
            guard data != nil, error == nil else {return}
            if let response = resp as? HTTPURLResponse {
                if(200...299).contains(response.statusCode){
                    DispatchQueue.main.async {
                        for id in body.ids {
                            if let idOnDisplay = self.messagesToDisplay.firstIndex(where: {$0.id == id}){
                                self.messagesToDisplay.remove(at: idOnDisplay)
                            }
                        }
                        self.selectedMesagesToDelete = []
                        self.loadFolders()
                    }
                }
            }
        }
        task.resume()
    }
    
    func deleteFolder() async{
        DispatchQueue.main.async {
            self.selectedMesagesToDelete = []
        }
        do {
            if let data = try await getAllIdsOfFolder() {
                DispatchQueue.main.async {
                    for i in data.messages {
                        self.selectedMesagesToDelete.append(MessagesToDisplay(id: i.id, title: "", text: "", date: ""))
                    }
                    self.deleteMessages()
                }
                
            }
        } catch {
            print(error)
        }
    }
    
    func getAllIdsOfFolder() async throws -> FolderMessagesResponse? {
        guard let id = selectedFolderToDelete?.id else { return nil }
        guard let url = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages?labelIds=\(id)&maxResults=500") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(gAccount!.accessToken.tokenString)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response: \(response)")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(FolderMessagesResponse.self, from: data)
//            print(decodedData)
            return decodedData
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }

}

