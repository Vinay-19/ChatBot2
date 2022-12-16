//
//  ContentView.swift
//  ChatGPT2
//
//  Created by Vinay Kumar Thapa on 2022-12-16.
//

import SwiftUI
import OpenAISwift


final class ViewModel: ObservableObject{
    
    private var client: OpenAISwift?
    
    func setUp() {
        client = OpenAISwift(authToken: Constants.API_Key)
    }
    func send(input: String, completion: @escaping(String)->Void) {
        
        client?.sendCompletion(with: input, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let response = model.choices.first?.text ?? ""
                completion(response)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading){
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            
            Spacer()
            
            HStack{
                TextField("Type here...", text: $text)
                Button("Send"){
                    send()
                }
            }
        }
        .onAppear {
            viewModel.setUp()
        }
        .padding()
    }
    
    func send() {
    
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append("Me: \(text)")
        models.append(" ")
        viewModel.send(input: text) { response in
            DispatchQueue.main.async {
                print(response)
                self.models.append("ChatGPT: " + response)
                self.models.append(" ")
                self.text = ""
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
