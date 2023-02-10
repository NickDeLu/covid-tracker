//
//  ContentView.swift
//  assignment2_delunico
//
//  Created by Nick De Luca on 2022-12-07.
//

import SwiftUI

//@@FIXME: fix overlapping touching area of 2 Picker views
//Reference: https://developer.apple.com/forums/thread/687986?answerId=706782022#706782022
extension UIPickerView {
    open override var intrinsicContentSize: CGSize { return CGSize(width: UIView.noIntrinsicMetric,
                                                                   height: UIView.noIntrinsicMetric)
    }
}

struct ContentView: View {
    @State var url: URL? = Bundle.main.url(forResource: "test_chart", withExtension: "html", subdirectory: "chart_html")
    @StateObject var message = WebViewMessage();
    @StateObject var viewModel = Covid19ViewModel()
    @State private var allTime = false
    
    var body: some View {
        AdaptiveStack{
            //weeks piccker
            VStack{
                // Picker for province in body view
                Text("COVID-19: \(viewModel.currentProvince)").font(.title)
                Picker("Province", selection: $viewModel.currentProvince) {             // dollar sign is bidrectional binding picker will also update the viewmodel property
                    Text("CA").tag("Canada")
                    Text("ON").tag("Ontario")
                    Text("QC").tag("Quebec")
                    Text("BC").tag("British Columbia")
                    Text("AB").tag("Alberta")
                    Text("MB").tag("Manitoba")
                }
                .pickerStyle(.segmented)
                .clipped()
                .onChange(of: viewModel.currentProvince) { tag in
                    // change province data then update the chart vm.changeProvince()
                    viewModel.changeProvince()
                }
                
                Picker("weeks", selection:$viewModel.currentWeekIndex) {
                    ForEach(0 ..< viewModel.weeks.count, id: \.self){ i in
                        Text(viewModel.weeks[i]).tag(i)
                    }
                }.pickerStyle(.wheel)
                    .frame(height:100)
                    .clipped()
                    .onChange(of: viewModel.currentWeekIndex) { tag in
                        viewModel.changeWeek()
                    }
                Text("Confirmed Cases")
                HStack{
                    VStack(alignment: .leading){
                        Text("Weekly").font(.system(size: 20).bold())
                        Text("\(viewModel.currentWeeklyCases)").font(.system(size: 25)).foregroundColor(.blue)
                    }
                    VStack(alignment: .leading){
                        Text("Total").font(.system(size: 20).bold())
                        Text("\(viewModel.currentTotalCases)").font(.system(size: 25)).foregroundColor(.red)
                    }
                }.padding(.leading, 20).padding(.top, 1)
                Text(verbatim:"Source: https://health-infobase.canada.ca").font(.system(size: 15)).foregroundColor(.gray).padding(.top, 1)
            }.padding(.init(top: 5, leading: 5, bottom: 0, trailing: 5))
            VStack{
                ZStack{
                    
                    Toggle("Switch", isOn: $allTime).onChange(of: allTime, perform: { value in
                        var dict: [String:Any] = [:]
                        if(value){
                            let yvalues = viewModel.jsonData.map({$0.totalCases})
                            let xvalues = viewModel.jsonData.map({$0.date})
                            dict["xs"] = xvalues   // x-values
                            dict["ys"] = yvalues // y-values
                            let json = viewModel.toJsonString(from: dict)
                            viewModel.message.js = "drawChart(\(json), 'Confirmed Cases All Time')"
                        }else{
                            viewModel.changeProvince()
                        }
                    })
                    .toggleStyle(.button)
                    .zIndex(1)
                    .frame(maxWidth:350, maxHeight: 550, alignment: .topTrailing)
                    
                    
                    WebView(url: url, message: message)
                }
            }
        }.onAppear(){
            viewModel.message = message
            viewModel.fetchData()
        }.alert("Failed to generate URL", isPresented: $viewModel.failedUrl, actions: {
            Button("OK", role: .cancel) { }
        })
        .alert("Failed to decode JSON", isPresented: $viewModel.failedDecode, actions: {
            Button("OK", role: .cancel) { }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
