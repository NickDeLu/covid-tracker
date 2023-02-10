//
//  Covid19ViewModel.swift
//  assignment2_delunico
//
//  Created by Nick De Luca on 2022-12-07.
//

import Foundation

struct Covid19Data: Codable {
    var provinceName: String = "CA"
    var date: String = ""
    var totalCases: Int = 0
    var weeklyCases: Int = 0
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        provinceName = try container.decode(String.self, forKey: .provinceName)
        date = try container.decode(String.self, forKey: .date)
        totalCases = Int(try container.decode(String.self, forKey: .totalCases)) ?? 0
        weeklyCases = Int(try container.decode(String.self, forKey: .weeklyCases)) ?? 0
    }
    
    enum CodingKeys: String, CodingKey
    {
        case provinceName = "prname"
        case date = "date"
        case totalCases = "totalcases"
        case weeklyCases = "numtotal_last7"
    }
}

class Covid19ViewModel: ObservableObject {
    
    var jsonData: [Covid19Data] = []
    var provinceData: [Covid19Data] = []
    @Published var message = WebViewMessage()
    @Published var currentWeekIndex = 0
    @Published var failedUrl = false
    @Published var failedDecode = false
    @Published var currentProvince: String = ""
    @Published var currentWeeklyCases: Int = 0
    @Published var currentTotalCases: Int = 0
    @Published var weeks: [String] = []
    
    func fetchData (){
        let urlString = "https://health-infobase.canada.ca/src/data/covidLive/covid19.json"
        guard let url = URL(string: urlString) else {
            print("Failed to generate URL")
            failedUrl = true
            return
        }
        
        // create URLSessionDataTask
        let ss = URLSession.shared
        let task = ss.dataTask(with: url,
                               completionHandler: { (data, resp, err) in
            // 1. cehck error first
            if let error = err {
                print(error.localizedDescription)
                return
            }
            // 2. check data
            guard let data = data else {
                print("Data is nil")
                return
            }
            // 3. parse JSON
            let decoder = JSONDecoder()
            if let json = try? decoder.decode([Covid19Data].self,
                                              from: data) {
                // success, update data in main thread
                DispatchQueue.main.async {
                    self.jsonData = json
                    self.parseJson()
                }
            }
            else {
                print("Failed to decode JSON")
                self.failedDecode = true
            }
        })
        task.resume() // perform the task
    }
    
    func parseJson(){
        // set date format as ISO
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // compute # of dates to set the array size of values
        let SEC_PER_WEEK: Double = 60 * 60 * 24 * 7
        let firstWeek = dateFormatter.date(from: jsonData[0].date) ?? Date()
        let lastWeek = dateFormatter.date(from: jsonData[ jsonData.count - 1 ].date) ?? Date()
        let sec = lastWeek.timeIntervalSince(firstWeek)
        let weekCount = Int(sec / SEC_PER_WEEK + 0.5) + 1
        
        self.weeks = [String](repeating: "", count: weekCount)
        
        for i in 0 ..< weekCount {
            let week = firstWeek + (Double(i) * SEC_PER_WEEK)
            self.weeks[i] = dateFormatter.string(from: week)
        }
        currentProvince = "Canada"
        changeProvince()
        currentWeekIndex = weeks.count - 1
    }
    
    func changeProvince(){
        provinceData = jsonData.filter({$0.provinceName == currentProvince})
        
        let values = provinceData.map({$0.weeklyCases})
        
        var dict: [String:Any] = [:]
        dict["xs"] = weeks   // x-values
        dict["ys"] = values // y-values
        let json = toJsonString(from: dict)
        message.js = "drawChart(\(json), 'Weekly Confirmed Cases')"

        // 4. call changeWeek() after change province
        changeWeek()
    }
    
    func changeWeek(){
        currentWeeklyCases = provinceData[currentWeekIndex].weeklyCases
        currentTotalCases = provinceData[currentWeekIndex].totalCases
    }
    
    func toJsonString(from: Any) -> String {
        // NOTE: you may use JSONEncoder instead,
        // but the object must conform Encodable protocol
        if let data = try? JSONSerialization.data(withJSONObject: from,
                                                  options: []),
           let jsonString = String(data: data, encoding: .utf8)
        {
            return jsonString
        } else {
            return "{}" }
    }
}
