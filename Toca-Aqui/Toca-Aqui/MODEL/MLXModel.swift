import SwiftUI
import MLXLLM
import MLXLMCommon


extension Content_Camera_View {
    /*
    func generate(recognisedText: String, downloadProgress: Binding<Double>) async throws {
        let modelConfiguration = ModelRegistry.llama3_2_1B_4bit
        let modelContainer = try await LLMModelFactory.shared.loadContainer(configuration: modelConfiguration) { progress in
           
            DispatchQueue.main.async {
                downloadProgress.wrappedValue = progress.fractionCompleted
            }
            debugPrint("Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%")
        }

        let prompt = "Do a meaningful summary of this text: \(recognisedText)"

        let _ = try await modelContainer.perform { [prompt] context in
            let input = try await context.processor.prepare(input: .init(prompt: prompt))

            return try MLXLMCommon.generate(
                input: input, parameters: .init(), context: context) { tokens in
                    let text = context.tokenizer.decode(tokens: tokens)

                    Task { @MainActor in
                        self.output = text
                    }
                    return .more
                }
        }
     
    }*/
    
    func generate(structuredText: [(text: String, isTitle: Bool)], downloadProgress: Binding<Double>) async throws {
        let modelConfiguration = ModelRegistry.llama3_2_1B_4bit
        let modelContainer = try await LLMModelFactory.shared.loadContainer(configuration: modelConfiguration) { progress in
            DispatchQueue.main.async {
                downloadProgress.wrappedValue = progress.fractionCompleted
            }
            debugPrint("Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%")
        }
        
        var processedText = ""
        for (text, isTitle) in structuredText {
            // Adjust the prompt based on whether the text is a title.
            let prompt = isTitle ?
                "Summarize this title while keeping it clear: \(text)" :
                "Summarize this paragraph while preserving its structure: \(text)"
            
            let _ = try await modelContainer.perform { [prompt] context in
                let input = try await context.processor.prepare(input: .init(prompt: prompt))
                return try MLXLMCommon.generate(
                    input: input, parameters: .init(), context: context) { tokens in
                        return .more
                    }
            }
            
            // For now, we just append the original text.
            processedText.append("\(text)\n")
        }
        
        DispatchQueue.main.async {
            self.output = processedText
        }
    }
}


