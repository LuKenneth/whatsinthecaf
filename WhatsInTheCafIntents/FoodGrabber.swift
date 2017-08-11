//
//  FoodGrabber.swift
//  SiriPlayground
//
//  Created by Luke Patterson on 3/24/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import Intents

class FoodGrabber {
    
    static let sharedInstance: FoodGrabber = FoodGrabber()
    private init(){}
    private var menu: [String:String] = [:]
    private let stations:[String] = ["Comfort", "Deli", "Dessert", "Grill", "International", "Pizza", "Salad", "Soup, Rice and Beans"
    , "Vegetarian"]
    
    public var menuString = ""
    func grabStation(station: String) -> String {
        
        var returnString = ""
        let data = NSData(contentsOf: NSURL(string: "https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478&PeriodId=1327&MenuDate=2017-05-12&Mode=day&UIBuildDateFrom=2017-05-12")! as URL)
        //https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478
        //https://jcu.campusdish.com/Commerce/Catalog/Menus.aspx?LocationId=3478&PeriodId=1327&MenuDate=2017-05-12&Mode=day&UIBuildDateFrom=2017-05-12
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
                
                returnString = ""
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
        
        for index in 0...stations.count - 1 {
            
            menu[stations[index]] = grabStation(station: stations[index])
        }
        
    }
    
    func readAvailableMenus() -> String{
        
        grabAllStations()
        
        var returnString = "The menu includes:"
        var isEmpty = true
        for (station, food) in menu {
            
            if food != "" {
                
                isEmpty = false
                returnString += "In the \(station) station, \(food), "
            }
        }
        
        if(isEmpty) {
            returnString = "Sorry, looks like there's nothing on the menu for today!"
        }
        menuString = returnString
        return returnString
    }
    
    func grabMenu() ->String {
        
        if(menuString == "") {
            menuString = readAvailableMenus()
        }
        
        return menuString
    }
    
    func generateMessage() -> INMessage {
        grabAllStations()
        var content = ""
        if(menu["Comfort"] != "") {
            content = "The menu includes: \(menu["Comfort"]!)"
        }
        
        if(menu["Grill"] != "" && menu["Comfort"] != "") {
            content += " and on the grill they're serving: \(menu["Grill"]!)"
        }
        else if(menu["Grill"] != "") {
            
            content = "The menu includes: \(menu["Grill"]!)"
        }
        else {
            content = "Sorry, look's like there's nothing special on the menu for today!"
        }
        let message = INMessage(identifier: "Menu", content: content, dateSent: Date(),
                                sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Deli", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                                recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)])
        return message
    }

}
