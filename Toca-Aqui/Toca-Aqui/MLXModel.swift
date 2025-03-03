import SwiftUI
import MLXLLM
import MLXLMCommon


extension Content_Camera_View {
     func generate(recognisedText: String) async throws {
        let modelConfiguration = ModelRegistry.llama3_2_1B_4bit
        let modelContainer = try await LLMModelFactory.shared.loadContainer(configuration: modelConfiguration) { progress in
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
        
        
    }
}
