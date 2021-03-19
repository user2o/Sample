//
//  LookupDetailSwiftUI.swift
//  Sample
//
//  Created by user2o on 18.03.21.
//

import SwiftUI

struct LookupDetailSwiftUI: View {
    
    @ObservedObject var resolver: OMDBResolver
    #if DEBUG
    var testItem: OMDBItem?
    #endif
    
    var body: some View {
        
        #if DEBUG
        let resolved = resolver.item ?? testItem
        #else
        let resolved = resolver.item
        #endif
        
        if let item = resolved {
            
            ScrollView {
                LazyVStack {
                    
                    Group {
                        makeTitle(title: item.title)
                        makePoster(poster: Poster(url: item.poster))
                        makeHSummary(released: item.released,
                                     runtime: item.runtime,
                                     rated: item.rated)
                    }
                    
                    Group {
                        makeHeadline(title: "Plot")
                        makeText(content: item.plot)
                        
                        makeHeadline(title: "Genre")
                        makeText(content: item.genre)
                        
                        makeHeadline(title: "Writer")
                        makeText(content: item.writer)
                        
                        makeHeadline(title: "Actors")
                        makeText(content: item.actors)
                    }
                    
                    Group {
                        Text("⭐️ IMDB Rating")
                            .font(.caption)
                            .textCase(.uppercase)
                            .padding(.top, 12)
                        
                        Text("\(item.imdbRating) / 10")
                            .font(.largeTitle)
                    }
                    
                }
                .padding([.leading, .trailing], 24)
                .onAppear() {
                    UITableView.appearance().separatorStyle = .none
                }
            }
        }
        else if let error = resolver.error {
            makeError(error: error)
        }
        else if resolver.item == nil {
            makeActivity()
        }
    }
}

struct LookupDetailSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        
        let resolver = OMDBResolver(searchResult: testSearchResultItem)
        
        #if DEBUG
        LookupDetailSwiftUI(resolver: resolver,
                            testItem: testOMDBItem)
        #else
        LookupDetailSwiftUI(resolver: resolver)
        #endif
    }
}

struct makeTitle: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title)
            .multilineTextAlignment(.center)
            .padding(.top, 10)
    }
}

struct makePoster: View {
    @ObservedObject var poster: Poster
    var body: some View {
        Image(uiImage: poster.image)
            .resizable()
            .scaledToFit()
            .cornerRadius(20.0)
            .animation(.linear(duration: 0.125))
            .aspectRatio(2/3, contentMode: .fit)
    }
}

struct makeHSummary: View {
    
    var released: String
    var runtime: String
    var rated: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack{
                Text("Released")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(released)
            }
            Spacer()
            VStack{
                Text("Runtime")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(runtime)
            }
            Spacer()
            VStack{
                Text("Rated")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(rated)
            }
            Spacer()
        }
        .padding(.bottom, 8)
    }
}

struct makeHeadline: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 8)
    }
}

struct makeText: View {
    var content: String
    var body: some View {
        Text(content)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct makeError: View {
    var error: String
    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon")
                .resizable()
                .frame(width: 96, height: 96, alignment: .center)
                .foregroundColor(.secondary)
            
            Text("Error")
                .font(.headline)
                .padding(.top, 8)
            
            Text(error)
                .font(.footnote)
                .italic()
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 32)
                .padding(.top, 4)
        }
    }
}

struct makeActivity: View {
    var body: some View {
        VStack {
            ActivityIndicator()
            Text("Fetching Details")
                .font(.headline)
            Text("please stand by")
                .font(.footnote)
                .italic()
        }
    }
}
