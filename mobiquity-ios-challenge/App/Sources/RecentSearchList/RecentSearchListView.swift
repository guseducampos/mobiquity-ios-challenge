//
//  RecentSearchListView.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 30/8/21.
//

import SwiftUI

struct RecentSearchListView: View {
    @ObservedObject var viewModel: RecentSearchListViewModel

    let selectedItem: (SearchItem) -> Void
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Recent Search")
                    .font(.title2)
                    .padding([.leading, .top])
                Spacer()
            }
            List(viewModel.searchItems) { item in
                Text(item.name)
                    .padding()
                    .onTapGesture {
                        selectedItem(item)
                    }
            }
        }
    }
}

struct RecentSearchListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchListView(
            viewModel: .init(service: .init(saveRecent: { _ in
                fatalError("")
            }, getRecentsSearch: {
                fatalError("")
            }))
        ) { _ in
            
        }
    }
}
