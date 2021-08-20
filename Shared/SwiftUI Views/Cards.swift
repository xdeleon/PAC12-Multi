//
//  Cards.swift
//  PAC-12 Multi
//
//  Created by Xavier De Leon on 8/19/21.
//

import SwiftUI
import SDWebImage

//struct CardsView: View {
//    @ObservedObject var cardsViewModel = CardsViewModel()
//    @State var showAlert = false
//
//    var body: some View {
//        ScrollView {
//            LazyVStack {
//                ForEach(1...100, id: \.self) { value in
//                    VStack(spacing: 0) {
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text(schools).foregroundColor(Color("PAC12-Yellow"))
//                            Text(sports).foregroundColor(.white)
//                        }   .padding(.horizontal, 10)
//                            .background(Color("PAC12-Blue"))
//                            .font(.system(size: 10))
//                            .lineLimit(2)
//                            .frame(height: 60)
//                        ZStack {
//                            Image("sample").resizable().scaledToFit()
//                            Spacer()
//                            VStack {
//                                Spacer()
//                                HStack {
//                                    Text("00:00").padding(.horizontal, 10).padding(.vertical, 5).background(Color.black).cornerRadius(5)
//                                    Spacer()
//                                    Text("5").padding(.horizontal, 10).padding(.vertical, 5).background(Color("PAC12-Red")).cornerRadius(5)
//                                }.foregroundColor(.white).padding(.horizontal, 20).padding(.bottom, 10)
//                            }
//                        }
//                        Spacer()
//                        Text(longText).foregroundColor(.white).lineLimit(2).padding(10)
//                    }   .frame(height: 310)
//                        .background(Color("PAC12-Dark Gray"))
//                        .foregroundColor(.white)
//                        .font(.system(size: 12))
//                        .onTapGesture {
//                            self.showAlert.toggle()
//                        }
//                        .alert(isPresented: self.$showAlert) {
//                            Alert(title: Text("Just An Assesssment"), message: Text("Move along now. Nothing else here to see..."))
//                        }
//                    Spacer()
//                }
//            }.padding(10).background(Color.black)
//        }.onAppear {
//            getSchools()
//            getSports()
//            getVideos()
//        }
//    }
//}

struct CardsView: View {
    let schools = "xxxxx, xxxxx, xxxxx, xxxxx"
    let sports = "22222, 22222, 22222, 22222"

    @ObservedObject var vm = CardsViewModel()
    @State var showAlert = false

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.vodPrograms, id: \.self) { card in
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack { Spacer() }
                            Text(schools).foregroundColor(Color("PAC12-Yellow"))
                            Text(sports).foregroundColor(.white)
                        }   .padding(.horizontal, 10)
                            .background(Color("PAC12-Blue"))
                            .font(.system(size: 10))
                            .lineLimit(2)
                            .frame(height: 60)

                        ZStack {
                            Image("sample").resizable().scaledToFit()
                            Spacer()
                            VStack {
                                Spacer()
                                HStack {
                                    Text("00:00").padding(.horizontal, 10).padding(.vertical, 5).background(Color.black).cornerRadius(5)
                                    Spacer()
                                    Text("5").padding(.horizontal, 10).padding(.vertical, 5).background(Color("PAC12-Red")).cornerRadius(5)
                                }.foregroundColor(.white).padding(.horizontal, 20).padding(.bottom, 10)
                            }
                        }
                        Spacer()
                            Text(card.title).foregroundColor(.white).lineLimit(2).padding(10).frame(maxWidth: .infinity)
                    }   .frame(height: 310)
                        .background(Color("PAC12-Dark Gray"))
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                        .onTapGesture {
                            self.showAlert.toggle()
                        }
                        .alert(isPresented: self.$showAlert) {
                            Alert(title: Text("Just An Assesssment"), message: Text("Move along now. Nothing else here to see..."))
                        }
                    Spacer()
                }
            }.padding(10).background(Color.black)
        }
    }
}
