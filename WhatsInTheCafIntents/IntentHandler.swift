//
//  IntentHandler.swift
//  SiriPlaygroundIntents
//
//  Created by Luke Patterson on 3/14/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//
/*
import Intents
import Foundation

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"
class IntentHandler: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    
     // MARK: - INSendMessageIntentHandling
     
     // Implement resolution methods to provide additional information about your intent (optional).
     func resolveRecipients(forSendMessage intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void) {
     if let recipients = intent.recipients {
     
     // If no recipients were provided we'll need to prompt for a value.
     if recipients.count == 0 {
     completion([INPersonResolutionResult.needsValue()])
     return
     }
     
     var resolutionResults = [INPersonResolutionResult]()
     for recipient in recipients {
     let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
     switch matchingContacts.count {
     case 2  ... Int.max:
     // We need Siri's help to ask user to pick one from the matches.
     resolutionResults += [INPersonResolutionResult.disambiguation(with: matchingContacts)]
     
     case 1:
     // We have exactly one matching contact
     resolutionResults += [INPersonResolutionResult.success(with: recipient)]
     
     case 0:
     // We have no contacts matching the description provided
     resolutionResults += [INPersonResolutionResult.unsupported()]
     
     default:
     break
     
     }
     }
     completion(resolutionResults)
     }
     }
     
     func resolveContent(forSendMessage intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
     if let text = intent.content, !text.isEmpty {
     completion(INStringResolutionResult.success(with: text))
     } else {
     completion(INStringResolutionResult.needsValue())
     }
     }
     
     // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
     
     func confirm(sendMessage intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
     // Verify user is authenticated and your app is ready to send a message.
     
     let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
     let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
     completion(response)
     }
     
     // Handle the completed intent (required).
     
     func handle(sendMessage intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
     // Implement your application logic to send a message here.
     
     let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
     let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
     completion(response)
     }
     
     // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
     
     // MARK: - INSearchForMessagesIntentHandling
     
     func handle(searchForMessages intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
     // Implement your application logic to find a message that matches the information in the intent.
     
     let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
     let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
     // Initialize with found message's attributes
     response.messages = [INMessage(
     identifier: "Comfort",
     content: FoodGrabber.sharedInstance.grabStation(station: "Comfort"),
     dateSent: Date(),
     sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Comfort", image: nil,  contactIdentifier: nil, customIdentifier: nil),
     recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
     ),
        
                          INMessage(
                            identifier: "Grill",
                            content: FoodGrabber.sharedInstance.grabStation(station: "Grill"),
                            dateSent: Date(),
                            sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Grill", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                            recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
        ),
                          INMessage(
                            identifier: "Deli",
                            content: FoodGrabber.sharedInstance.grabStation(station: "Deli"),
                            dateSent: Date(),
                            sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Deli", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                            recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
        ),
                          INMessage(
                            identifier: "Dessert",
                            content: FoodGrabber.sharedInstance.grabStation(station: "Dessert"),
                            dateSent: Date(),
                            sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Dessert", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                            recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
        ),
                          INMessage(
                            identifier: "International",
                            content: FoodGrabber.sharedInstance.grabStation(station: "International"),
                            dateSent: Date(),
                            sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "International", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                            recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
        ),
                          INMessage(
                            identifier: "Vegetarian",
                            content: FoodGrabber.sharedInstance.grabStation(station: "Vegetarian"),
                            dateSent: Date(),
                            sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Vegetarian", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                            recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
        ),
                          INMessage(
                            identifier: "Pizza",
                            content: FoodGrabber.sharedInstance.grabStation(station: "Pizza"),
                            dateSent: Date(),
                            sender: INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Pizza", image: nil,  contactIdentifier: nil, customIdentifier: nil),
                            recipients: [INPerson(personHandle: INPersonHandle(value: "lpatterson18@jcu.edu", type: .emailAddress), nameComponents: nil, displayName: "Luke", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
        ),
        ]
     completion(response)
     }
     
     // MARK: - INSetMessageAttributeIntentHandling
     
     func handle(setMessageAttribute intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
     // Implement your application logic to set the message attribute here.
     
     let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
     let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
     completion(response)
     }

    
    
    
    
    
    
    
    
    
    
    

    //func handle(searchCallHistory: INSearchCallHistoryIntent, completion: @escaping (INSearchCallHistoryIntentResponse) -> Void) {
        //INVocabularyStringType.contactName
    //}
    
    
    
    // MARK: INBook​Restaurant​Reservation​Intent​Handling
    /*func handle(bookRestaurantReservation intent: INBookRestaurantReservationIntent,
                completion: @escaping (INBookRestaurantReservationIntentResponse) -> Void){
        
    }*/
    
    
    
    // MARK: - INSearchForPhotosIntentHandling
    /*
    func handle(searchForPhotos intent: INSearchForPhotosIntent,
                completion: @escaping (INSearchForPhotosIntentResponse) -> Void){
        
    }
 

    
    func confirm(searchForPhotos intent: INSearchForPhotosIntent,
                          completion: @escaping (INSearchForPhotosIntentResponse) -> Void){
        
    }*/
    
    
    }

*/
