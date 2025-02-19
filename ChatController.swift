
import Foundation
import OpenAI
import CoreLocation // Make sure you import CoreLocation for userLocation

class ChatController: ObservableObject {
    @Published var disposalMethod: String? = nil
    @Published var disposalCategory: String? = nil
    
    let openAI = OpenAI(apiToken: "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")
    
    
    func getDisposalMethod(for item: String, completion: @escaping (String, String) -> Void) {
        let prompt = """
        Classify the disposal method for the item: \(item).
        The possible disposal methods are: 'Recyclable', 'Compostable', 'Hazardous Waste', 'Donation', 'Scrapyard', 'Landfill', 'General Trash', 'Household Waste', 'Unrecyclable Waste', 'No disposal method found'.

        Now, confirm whether the disposal method falls into one of these categories: 'Recyclable', 'Compostable', 'Hazardous Waste', 'Donation', 'Scrapyard', 'Landfill', 'General Trash', 'Household Waste', 'Unrecyclable Waste'. Respond ONLY with the method and category, separated by a newline.
        """

        if let messageParam = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) {
            let query = ChatQuery(
                messages: [messageParam],
                model: .gpt3_5Turbo
            )
            
            openAI.chats(query: query) { result in
                switch result {
                case .success(let success):
                   
                    print("Full API Response: \(success)")

                    guard let choice = success.choices.first else {
                        print("No choices found in the response")
                        completion("No disposal method found", "No category found")
                        return
                    }

                   
                    if case let .assistant(assistantMessage) = choice.message {
                        if let messageContent = assistantMessage.content {
                            
                            print("Message Content: \(messageContent)")

                            let messageParts = messageContent.components(separatedBy: "\n")

                            if messageParts.count >= 2 {
                                let disposalMethod = messageParts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                let disposalCategory = messageParts[1].trimmingCharacters(in: .whitespacesAndNewlines)

                                print("Disposal method: \(disposalMethod), Category: \(disposalCategory)")  // Debugging
                                completion(disposalMethod, disposalCategory)
                            } else {
                                completion("No disposal method found", "No category found")
                            }
                        } else {
                            print("Message content is nil")
                            completion("No disposal method found", "No category found")
                        }
                    } else {
                        print("No valid assistant message")
                        completion("No disposal method found", "No category found")
                    }

                case .failure(let failure):
                    print("API Failure: \(failure.localizedDescription)")  // Detailed failure logging
                    completion("No disposal method found", "No category found")
                }
            }
        } else {
            print("Failed to create messageParam")
            completion("No disposal method found", "No category found")
        }
    }
    
    
    
   
    func getDisposalMethodAndFetchLocations(for item: String, userLocation: CLLocationCoordinate2D, completion: @escaping ([DisposalLocation]) -> Void) {
        getDisposalMethod(for: item) { disposalMethod, disposalCategory in
          
            fetchNearbyDisposalLocations(userLocation: userLocation, disposalCategory: disposalCategory) { locations in
            
                completion(locations)
            }
        }
    }
    
    
    
    
    func getItemWeight(for item: String, completion: @escaping (String) -> Void) {
        let prompt = """
        Estimate the average weight of the following item in pounds: \(item).
        Respond with only the weight as a number, without any extra explanation or units.
        Example: 0.05
        """


        if let messageParam = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) {
            let query = ChatQuery(
                messages: [messageParam],
                model: .gpt3_5Turbo
            )

            openAI.chats(query: query) { result in
                switch result {
                case .success(let success):
                    
                    print("Full API Response: \(success)")

                    guard let choice = success.choices.first else {
                        print("No choices found in the response")
                        completion("No weight found")
                        return
                    }

                 
                    if case let .assistant(assistantMessage) = choice.message {
                        if let messageContent = assistantMessage.content {
                            
                            print("Message Content: \(messageContent)")

                            let estimatedWeight = messageContent.trimmingCharacters(in: .whitespacesAndNewlines)

                            print("Estimated weight: \(estimatedWeight)")  // Debugging
                            completion(estimatedWeight)
                        } else {
                            print("Message content is nil")
                            completion("No weight found")
                        }
                    } else {
                        print("No valid assistant message")
                        completion("No weight found")
                    }

                case .failure(let failure):
                    print("API Failure: \(failure.localizedDescription)")  // Detailed failure logging
                    completion("No weight found")
                }
            }
        } else {
            print("Failed to create messageParam")
            completion("No weight found")
        }
    }

    
    
}
