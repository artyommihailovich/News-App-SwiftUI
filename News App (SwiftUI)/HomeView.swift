//
//  ContentView.swift
//  News App (SwiftUI)
//
//  Created by Artyom Mihailovich on 9/17/20.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI

struct HomeView: View {
    @ObservedObject var newsList = GetNewsData()
    
    var body: some View {
        NavigationView {
            List(newsList.newsDatas) { index in
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(index.title)
                            .font(.body)
                            .lineLimit(2)
                        
                        Text(index.description)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                    .padding()
                }
                
                if index.image != "" {
                    WebImage(url: URL(string: index.image), options: .highPriority, context: nil)
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(12)
                }
            }
            .navigationBarTitle(Text("News"))
            .font(.title)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


//MARK: New API Integration. - Get Data from resource.

struct NewsDataType: Identifiable {
    var id: String
    var title: String
    var description: String
    var image: String
    var url: String
}

class GetNewsData: ObservableObject {
    @Published var newsDatas = [NewsDataType]()
    
    init() {
        //Paste in variable source our URL from https://newsapi.org/docs/endpoints/top-headlines
        let sourceOfNews = "https://newsapi.org/v2/top-headlines?country=us&apiKey=405d28de2e87403b98106f5dbebd9878"
        
        let url = URL(string: sourceOfNews)!
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) {
            (data, _, error) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            
            for index in json["articles"] {
                let id = index.1["publishedAt"].stringValue
                let title = index.1["title"].stringValue
                let description = index.1["description"].stringValue
                let image = index.1["urlToImage"].stringValue
                let url = index.1["url"].stringValue
                
                DispatchQueue.main.async {
                    self.newsDatas.append(NewsDataType(id: id, title: title, description: description, image: image, url: url))
                }
            }
        }.resume()
    }
}

