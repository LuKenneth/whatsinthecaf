//
//  FoodGrabber.swift
//  SiriPlayground
//
//  Created by Luke Patterson on 3/24/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation

class FoodGrabber {
    
    static let sharedInstance: FoodGrabber = FoodGrabber()
    private init(){}
    private var menu: [String:String] = [:]
    private let stations:[String] = ["Comfort", "Deli", "Dessert", "Fresh Food Company", "Grill", "International", "Pizza", "Salad", "Soup, Rice and Beans"
    , "Vegetarian"]
    func grabStation(station: String) -> String {
        
        var returnString = "Sorry, there's nothing on the menu for the station you requested."
        let data = NSData(contentsOf: NSURL(string: "https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478")! as URL)
        let doc = TFHpple(htmlData: data as Data!)
        var stopIndex = 0
        var startIndex = 0
        //https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478&PeriodId=1326&MenuDate=2017-03-30&Mode=day&UIBuildDateFrom=2017-03-30
        //https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478&PeriodId=1325&MenuDate=2017-03-30&Mode=day&UIBuildDateFrom=2017-03-30
        if let elements = doc?.search(withXPathQuery: "//h2 | //a") as? [TFHppleElement] {
            
            var foundStopIndex = false;
            var foundStartIndex = false;
            
            for index in 0 ... elements.count - 1 {
                
                let content = elements[index].content.trimmingCharacters(in: .whitespacesAndNewlines)
                if(content == station && !foundStartIndex) {
                    
                    startIndex = index + 1
                    foundStartIndex = true
                    
                }
                else if((elements[index].content == "Comfort" ||
                    elements[index].content == "Deli" ||
                    elements[index].content == "Dessert" ||
                    elements[index].content == "Fresh Food Company" ||
                    elements[index].content == "Grill" ||
                    elements[index].content == "International" ||
                    elements[index].content == "Pizza" ||
                    elements[index].content == "Salad" ||
                    elements[index].content == "Soup, Rice and Beans" ||
                    elements[index].content == "Vegetarian" ||
                    elements[index].content == "Hours of Operation") && !foundStopIndex && foundStartIndex) {
                    
                    stopIndex = index - 1
                    foundStopIndex = true
                }
            }
            if(startIndex<stopIndex) {
                
                returnString = "Today's menu includes: "
                for i in startIndex ... stopIndex - 1 {
                    
                    returnString = returnString + elements[i].content + ", "
                }
                
                returnString = returnString + "and " + elements[stopIndex].content
            }
            
            
        }
        return returnString
    }
    
    func observe() {
        let data = NSData(contentsOf: NSURL(string: "https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478")! as URL)
        let doc = TFHpple(htmlData: data as Data!)
        
        if let elements = doc?.search(withXPathQuery: "//h2 | //a") as? [TFHppleElement] {
            
            for index in 0 ... elements.count - 1{
                
                print("\(index):" + "\(elements[index].content!)" + ":end")
                
            }
            
        }
        
        
    }
    
    func grabAllStations() {
        
        for index in 0...stations.count {
            
            menu[stations[index]] = grabStation(station: stations[index])
        }
        
    }
    

}
