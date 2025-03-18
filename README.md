 Origo

Origo is an iOS application built with SwiftUI that allows users to scan documents, process the recognized text using an integrated LLM model, and generate structured, formatted PDFs. 
The app also features a draggable bottom sheet for managing saved documents, PDF viewing using PDFKit and QuickLook, and animated loading states powered by Lottie.

## Features

- **Document Scanning:** Uses VisionKit's `VNDocumentCameraViewController` to scan documents and perform OCR with Vision’s `VNRecognizeTextRequest`.
- **Structured Text Recognition:** Groups OCR results into structured blocks (titles and body text) using custom heuristics.
- **LLM Integration:** Leverages an LLM model (e.g., Llama 3 2 1B 4bit) via MLXLLM to transform recognized text. In one flow, fuzzy matching detects if the scanned text corresponds to a predefined text (e.g., a liturgical text) and then converts it to a formatted, LIS-friendly version.
- **PDF Generation:** Generates PDFs from scanned and processed text. The app offers both simple and structured PDF generation—preserving formatting (titles, paragraphs) in the final PDF.
- **Document Persistence:** Utilizes SwiftData to store PDF metadata (file name, path, and creation date) so that users can manage and revisit saved documents.
- **Draggable Bottom Sheet:** A custom SwiftUI view that displays a grid of saved PDFs, allowing users to swipe up and down to reveal or hide the list.
- **PDF Viewing:** Integrates PDFKit and QuickLook for displaying generated PDFs.
- **Custom Animations:** Uses Lottie for animated loading indicators and enforces modal behavior (for example, the PDF preview modal cannot be dismissed interactively, only via a cancel button).

## Architecture and File Structure

- **DraggableBottomSheet.swift:**  
  Contains a custom SwiftUI view that creates a draggable bottom sheet. This sheet is used to display saved PDF documents.
  
  Code explanation:
  
  •	@Binding var offset:
  This is a binding to a CGFloat value that represents the vertical offset of the sheet.
	•	When offset is 0, the sheet is fully expanded (visible).
	•	When offset equals (maxHeight - minHeight), the sheet is collapsed.
	•	maxHeight & minHeight:
  These represent the maximum and minimum heights of the bottom sheet. They determine how far the sheet can be dragged.
	•	bottomMargin:
  This adds a fixed margin at the bottom of the sheet, allowing you to control the spacing from the screen’s bottom edge.
	•	content:
  This holds the view that will be displayed inside the bottom sheet.

  @GestureState private var dragOffset: CGFloat = 0
  This property keeps track of the temporary drag translation (how much the finger has moved during a drag gesture).
	•	@GestureState automatically resets when the gesture ends.


	•	dragRange:
  This is the total distance the sheet can travel. It’s the difference between maxHeight and minHeight.
	•	currentOffset:
  This combines the permanent offset with the temporary dragOffset (from the current gesture) to get the sheet’s current position on screen.

  The initializer accepts:
	•	A binding for offset.
	•	The maximum and minimum heights.
	•	A bottom margin.
	•	A closure (using @ViewBuilder) that creates the content view.
  The content is immediately built by calling the closure.

  Body:

  •	Drag Gesture:
	•	.updating:
  Updates the dragOffset with the vertical translation of the drag gesture.
	•	.onEnded:
  When the drag ends, it checks the translation:
	•	If the user dragged upward beyond a small threshold (10 points), it snaps the sheet open (offset becomes 0) with a quick spring animation.
	•	If the user dragged downward beyond the threshold, it snaps the sheet closed (offset becomes dragRange) with a slightly slower spring animation.


	•	VStack:
  Contains:
	•	Drag Handle:
  A small Capsule view (a pill shape) that visually indicates the sheet is draggable.
	•	Content:
  The actual content provided by the user of the component.
  
	•	Frame & Background:
	•	The sheet’s frame spans the full width of the screen and has a height of maxHeight.
	•	It uses a rounded rectangle as a background with a white fill, giving the sheet a clean look.

	•	Offset and Gesture:
	•	The entire view is moved vertically by currentOffset + bottomMargin, placing it at the correct position.
	•	The drag gesture is attached to the view, enabling the dragging behavior.

- **PDFKitView.swift & PDFViewer.swift:**  
  These files wrap PDFKit’s `PDFView` in SwiftUI, enabling the app to display PDFs with features like auto-scaling and background customization.

  Code explanation:

  **PDFKitView:**
  
    This struct conforms to UIViewRepresentable, which allows us to integrate UIKit views (in this case, PDFView) into our SwiftUI code.
  	The pdfURL property is the location of the PDF file we want to display.

   What It Does:
  
	•	Container Setup:
  A UIView named containerView is created to serve as a container. It is given a very light purple background using an alpha value of 0.015.
  
	•	PDFView Creation:
  A PDFView is instantiated with the same size as the container.
	•	Autorezing Mask: Set to adjust with changes in size (.flexibleWidth and .flexibleHeight).
	•	AutoScales: The PDF will automatically scale to fit the view.
	•	BackgroundColor: Set to .clear so the container’s background shows through.
	•	Loading the PDF:
  The code attempts to load a PDFDocument from the provided pdfURL. If successful, the document is assigned to the PDFView, and a debug message is printed. Otherwise, it prints an error      message.
	•	Return:
The pdfView is added as a subview to the container, and then the container is returned.

	updateUIView: This function is required by UIViewRepresentable. In this case, there’s no dynamic update needed once the PDF is loaded, so it’s left empty.

  **PDFViewer:**

•	ZStack Layout:
The ZStack is used to layer views. Here, it places:
	•	Background Color:
A purple-colored background (with 30% opacity) that covers the whole screen.
	•	PDFKitView:
The view that displays the PDF.
	•	.onAppear Modifier:
When the PDFViewer appears, it prints the path of the PDF to the console and calls debugPrintPDFContents(url:) to print each page’s content. This is helpful for debugging and verifying that the PDF is loaded correctly.

Then there is the debugger function that serves just to debug
  

- **SavedPDF_Model.swift:**  
  Defines the `SavedPDF` model, which represents a scanned PDF. It uses SwiftData for persistence and includes properties like file name, file path (converted from a string), and creation date.

  Code Explanation:

  @Model // Marks this class as a SwiftData model, allowing it to be stored in a database
  class SavedPDF {
    @Attribute(.unique) var id: UUID // The @Attribute(.unique) ensures that each PDF has a distinct UUID.
    var fileName: String
    var filePathString: String // Stores the file path as a string (SwiftData does not support URL directly)
    var dateCreated: Date

    var filePath: URL {
        return URL(fileURLWithPath: filePathString)
    } // Converts the stored file path string back into a URL for use with PDFKit.
    
    init(fileName: String, filePath: URL) {
        self.id = UUID()  // Creates a unique identifier for each instance.
        self.fileName = fileName
        self.filePathString = filePath.path // Extracts the string path from the URL.
        self.dateCreated = Date() // Stores the current date as the creation date.
    }
}

	•	Annotations and Attributes:
	•	@Model tells SwiftData that this class should be stored in a database.
	•	@Attribute(.unique) on the id ensures each PDF gets a unique identifier.
	•	Properties:
	•	fileName: The name of the PDF file.
	•	filePathString: Since SwiftData cannot store a URL directly, the path is stored as a String.
	•	dateCreated: Records when the PDF was created.
	•	filePath (Computed Property):
  Converts the stored string back to a URL. This is useful for when you need to load the PDF using PDFKit or other APIs that require a URL.
	•	Initializer:
  Sets up a new SavedPDF instance with a unique ID, file name, file path (as a string), and the current date.


  PDF Generation Functions
  
  @discardableResult
  func generatePDF(text: String) -> URL? {
    let fileName = "TestPDF_\(UUID().uuidString).pdf"
    let pdfURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent(fileName)
    
    let format = UIGraphicsPDFRendererFormat()
    let pageSize = CGSize(width: 612, height: 792)
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
    
    do {
        try renderer.writePDF(to: pdfURL, withActions: { pdfContext in
            pdfContext.beginPage()
            let textRect = CGRect(x: 20, y: 20, width: pageSize.width - 40, height: pageSize.height - 40)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            attributedText.draw(in: textRect)
        })
        print("PDF generated at: \(pdfURL.path)")
        return pdfURL
    } catch {
        print("Failed to generate PDF: \(error)")
        return nil
    }
}


	•	Purpose: Generates a simple PDF from a plain text string.
	•	How It Works:
	•	File Path Creation: A unique file name is generated using a UUID, and the full file URL is constructed in the documents directory.
	•	UIGraphicsPDFRenderer: Sets up the renderer with a standard A4 page size (612x792 points).

	•	Drawing the PDF:
	•	Begins a new PDF page.
	•	Creates a text rectangle with margins.
	•	Sets text attributes (font and paragraph style) for proper formatting.
	•	Draws the attributed text into the rectangle.
	•	Return: Returns the URL where the PDF was saved.


func storePDF(url: URL, fileName: String, context: ModelContext) {
    let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
    let newFileName = trimmedName.isEmpty ? url.lastPathComponent : trimmedName
    
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return
    }
    
    let newURL = documentsDirectory.appendingPathComponent(newFileName)
    
    do {
        try FileManager.default.moveItem(at: url, to: newURL)
        
        let savedPDF = SavedPDF(fileName: newFileName, filePath: newURL)
        context.insert(savedPDF)
        print("PDF saved with custom name: \(newFileName)")
    } catch {
        print("Error renaming PDF: \(error)")
    }
}

	
 •	Purpose:
Moves the generated PDF file to a new URL (using a custom file name) and stores its metadata in SwiftData.
	
 •	Steps:
	•	File Name Sanitization: Trims extra spaces from the file name and uses the file’s last path component if the name is empty.
	•	File Move Operation: Uses FileManager to move (rename) the PDF file.
	•	Database Insert: Creates a new SavedPDF instance and inserts it into the SwiftData model context.
	•	Error Handling: Prints errors if the move operation fails.

 func classifyText(_ text: String) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .justified
    paragraphStyle.lineBreakMode = .byWordWrapping

    let attributes: [NSAttributedString.Key: Any]

    if isLikelyTitle(text) {
        attributes = [
            .font: UIFont.boldSystemFont(ofSize: 22), // Title formatting
            .paragraphStyle: paragraphStyle
        ]
    } else {
        attributes = [
            .font: UIFont.systemFont(ofSize: 16), // Body text formatting
            .paragraphStyle: paragraphStyle
        ]
    }
    
    return NSAttributedString(string: text, attributes: attributes)
}

	•	Purpose:
Takes a text string and returns an attributed string with formatting based on whether it is likely a title or body text.
	•	How It Works: Uses a helper function isLikelyTitle(_:) to decide if the text should be bold and larger (for titles) or regular (for body text).


func isLikelyTitle(_ text: String) -> Bool {
    return text.count < 50 && text == text.uppercased()
}


  •	Purpose:
  Determines if a piece of text is likely a title.
	•	Logic: If the text is short (less than 50 characters) and is fully in uppercase, it is assumed to be a title.


 func generateStyledPDF(text: String) -> URL? {
    let fileName = "Styled_Scanned_Document_\(UUID().uuidString).pdf"
    let pdfURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent(fileName)

    let format = UIGraphicsPDFRendererFormat()
    let pageSize = CGSize(width: 612, height: 792) // Standard A4 dimensions
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

    do {
        try renderer.writePDF(to: pdfURL, withActions: { pdfContext in
            pdfContext.beginPage()
            
            let textRect = CGRect(x: 20, y: 20, width: pageSize.width - 40, height: pageSize.height - 40)
            
            let formattedText = classifyText(text) // Apply formatting based on title or body.
            formattedText.draw(in: textRect)
        })
        print(" Styled PDF generated at: \(pdfURL.path)")
        return pdfURL
    } catch {
        print(" Failed to generate PDF: \(error)")
        return nil
    }
}


 •	Purpose: Generates a PDF from the provided text with styling applied (titles and body text are formatted differently).
	•	Process: Similar to the simple PDF generation function but calls classifyText(_:) to get an attributed string with formatting.
	•	Draws the attributed text within a specified rectangle.



func generateStructuredPDF(textSections: [(text: String, isTitle: Bool)],
                           documentName: String,
                           documentDate: Date,
                           logo: UIImage?) -> URL? {
    let fileName = "Structured_Scanned_Document_\(UUID().uuidString).pdf"
    let pdfURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        .appendingPathComponent(fileName)
    
    let format = UIGraphicsPDFRendererFormat()
    let pageSize = CGSize(width: 612, height: 792)  // Standard A4 dimensions
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
    
    do {
        var pageNumber = 1
        try renderer.writePDF(to: pdfURL, withActions: { pdfContext in
            // Start a new page and draw the header/footer layout.
            pdfContext.beginPage()
            let logoImage = UIImage(named: "Logo_Purple")
            drawPageLayout(in: pdfContext,
                           pageSize: pageSize,
                           pageNumber: pageNumber,
                           documentDate: documentDate,
                           logo: logoImage)
            
            // Start the content lower to allow space for the header.
            // We'll adjust the very first block if it's a title.
            var yOffset: CGFloat = 100   // Default starting offset.
            let xOffset: CGFloat = 20
            let maxWidth: CGFloat = pageSize.width - 40
            let spacingAfterBlock: CGFloat = 10
            
            // Flag to detect the first title block.
            var isFirstTitleProcessed = false
            
            var i = 0
            while i < textSections.count {
                var attrStr: NSAttributedString
                var blockHeight: CGFloat = 0
                
                if i < textSections.count - 1 && textSections[i].isTitle && !textSections[i+1].isTitle {
                    // Combining a title and its following body.
                    let combinedAttributedString = NSMutableAttributedString()
                    
                    // Use a larger font for the first title if not already processed.
                    let titleFontSize: CGFloat = (!isFirstTitleProcessed) ? 28 : 22
                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: titleFontSize),
                        .paragraphStyle: {
                            let ps = NSMutableParagraphStyle()
                            ps.alignment = .justified
                            ps.lineBreakMode = .byWordWrapping
                            return ps
                        }()
                    ]
                    let bodyAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 16),
                        .paragraphStyle: {
                            let ps = NSMutableParagraphStyle()
                            ps.alignment = .justified
                            ps.lineBreakMode = .byWordWrapping
                            return ps
                        }()
                    ]
                    
                    let titleText = textSections[i].text.trimmingCharacters(in: .whitespacesAndNewlines)
                    let bodyText = textSections[i+1].text.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    combinedAttributedString.append(NSAttributedString(string: titleText + "\n", attributes: titleAttributes))
                    combinedAttributedString.append(NSAttributedString(string: bodyText, attributes: bodyAttributes))
                    
                    let constraintRect = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                    blockHeight = ceil(combinedAttributedString.boundingRect(with: constraintRect,
                                                                              options: .usesLineFragmentOrigin,
                                                                              context: nil).height)
                    attrStr = combinedAttributedString
                    isFirstTitleProcessed = true
                    i += 2
                } else {
                    // Process a single block.
                    let block = textSections[i]
                    let attributes: [NSAttributedString.Key: Any]
                    if i == 0 && block.isTitle {
                        // First block is a title: use a larger font.
                        attributes = [
                            .font: UIFont.boldSystemFont(ofSize: 28),
                            .paragraphStyle: {
                                let ps = NSMutableParagraphStyle()
                                ps.alignment = .justified
                                ps.lineBreakMode = .byWordWrapping
                                return ps
                            }()
                        ]
                        isFirstTitleProcessed = true
                        // Adjust the starting yOffset to draw this block higher.
                        // For example, if default is 100, you can reduce it:
                        yOffset = 60
                    } else {
                        attributes = [
                            .font: block.isTitle ? UIFont.boldSystemFont(ofSize: 22) : UIFont.systemFont(ofSize: 16),
                            .paragraphStyle: {
                                let ps = NSMutableParagraphStyle()
                                ps.alignment = .justified
                                ps.lineBreakMode = .byWordWrapping
                                return ps
                            }()
                        ]
                    }
                    
                    attrStr = NSAttributedString(string: block.text, attributes: attributes)
                    let constraintRect = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                    blockHeight = ceil(attrStr.boundingRect(with: constraintRect,
                                                             options: .usesLineFragmentOrigin,
                                                             context: nil).height)
                    i += 1
                }
                
                // If not enough space for the block, start a new page.
                if yOffset + blockHeight + spacingAfterBlock > pageSize.height - 50 {
                    pdfContext.beginPage()
                    pageNumber += 1
                    drawPageLayout(in: pdfContext,
                                   pageSize: pageSize,
                                   pageNumber: pageNumber,
                                   documentDate: documentDate,
                                   logo: logo)
                    yOffset = 100
                }
                
                let textRect = CGRect(x: xOffset, y: yOffset, width: maxWidth, height: blockHeight)
                attrStr.draw(in: textRect)
                yOffset += blockHeight + spacingAfterBlock
            }
        })
        print("Structured PDF generated at: \(pdfURL.path)")
        return pdfURL
    } catch {
        print("Failed to generate PDF: \(error)")
        return nil
    }
}





This function is more complex—it creates a structured PDF that:
	•	Handles multiple pages.
	•	Includes headers and footers (drawn via drawPageLayout(...)).
	•	Supports merging consecutive blocks where a title is followed by its corresponding body text.
	•	Allows custom document name, document date, and logo image for branding.



func drawPageLayout(in context: UIGraphicsPDFRendererContext,
                    pageSize: CGSize,
                    pageNumber: Int,
                    documentDate: Date,
                    logo: UIImage?) {
    let cgContext = context.cgContext
    cgContext.setLineWidth(2.0)
    cgContext.setStrokeColor(UIColor.black.cgColor)
    
    // Draw the logo at the top right with 50% opacity.
    if let logo = logo {
        let logoSize = CGSize(width: 80, height: 80)
        let logoX = pageSize.width - 40 - logoSize.width
        let logoY: CGFloat = 30
        let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
        logo.draw(in: logoRect, blendMode: .normal, alpha: 0.5)
    }
    
    // Draw a horizontal line near the bottom.
    let bottomLineY: CGFloat = pageSize.height - 40
    cgContext.move(to: CGPoint(x: 20, y: bottomLineY))
    cgContext.addLine(to: CGPoint(x: pageSize.width - 20, y: bottomLineY))
    cgContext.strokePath()
    
    // Draw the document date on the bottom left.
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    let dateString = dateFormatter.string(from: documentDate)
    let dateAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12),
        .foregroundColor: UIColor.black
    ]
    let dateSize = dateString.size(withAttributes: dateAttributes)
    let dateRect = CGRect(x: 20, y: bottomLineY + 5, width: dateSize.width, height: dateSize.height)
    dateString.draw(in: dateRect, withAttributes: dateAttributes)
    
    // Draw the page number on the bottom right.
    let pageNumberString = "\(pageNumber)"
    let pageNumberAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 12),
        .foregroundColor: UIColor.black
    ]
    let pageNumberSize = pageNumberString.size(withAttributes: pageNumberAttributes)
    let pageNumberRect = CGRect(x: pageSize.width - 20 - pageNumberSize.width,
                                y: bottomLineY + 5,
                                width: pageNumberSize.width,
                                height: pageNumberSize.height)
    pageNumberString.draw(in: pageNumberRect, withAttributes: pageNumberAttributes)
}



- **Content_Camera_View.swift:**  
  The main view that ties together document scanning, text processing, LLM model integration, PDF generation, and the draggable bottom sheet. It listens for changes in recognized text and triggers model operations and PDF creation.

- **ScanDocumentView.swift:**  
  Wraps VisionKit’s document scanner and handles OCR using `VNRecognizeTextRequest`. It groups recognized text into structured blocks, applies fuzzy matching (to check for predefined texts), and triggers text transformation when needed.

- **LottieViewRepresentable.swift:**  
  Provides a SwiftUI wrapper for Lottie animations, used to show animated loading screens while the model downloads and processes text.

- **RootView.swift & WelcomeView.swift:**  
  Manage the app’s initial launch experience. `WelcomeView` displays a welcome screen with branding, and `RootView` transitions from the welcome screen to the main camera view.

- **Toca_AquiApp.swift:**  
  The app’s entry point, initializing SwiftData’s `ModelContainer` and setting up the root view.

## Key Components and Functionality

### Document Scanning and OCR

- **ScanDocumentView:**  
  Utilizes `VNDocumentCameraViewController` to capture images of documents. The OCR is performed via `VNRecognizeTextRequest`, grouping the results into paragraphs. The function `isLikelyTitle(_:)` determines if a text block should be treated as a title.

### LLM Integration Using the MLX Framework

- **Content_Camera_View Extension:**  
  Extends the main camera view with a function to process recognized, structured text using an LLM model.
  - **Function:** `generate(structuredText:downloadProgress:)`
    - **Model Loading:**  
      Uses `LLMModelFactory` and `ModelRegistry.llama3_2_1B_4bit` to load the model asynchronously. Progress is updated on the main thread.
    - **Processing Each Text Block:**  
      Iterates through each text section. For titles, it prompts the model with "Summarize this title while keeping it clear:"; for paragraphs, it uses "Summarize this paragraph while preserving its structure:".
    - **MLX Framework:**  
      The function calls `MLXLMCommon.generate` to perform the text generation. This framework abstracts model interactions, handling input preparation and token generation.
    - **Final Output:**  
      Appends the original text (or processed result) to a variable, then updates a SwiftUI property (`output`) on the main thread.

### PDF Generation

- **Simple PDF Generation (`generatePDF`):**  
  Creates a PDF from plain text using `UIGraphicsPDFRenderer`.

- **Styled PDF Generation (`generateStyledPDF`):**  
  Uses a helper (`classifyText`) to format text as a title (bold, larger font) or body (regular text) and draws it into a PDF.

- **Structured PDF Generation (`generateStructuredPDF`):**  
  Handles more complex documents:
  - Supports multi-page output.
  - Merges consecutive blocks where a title is followed by its body.
  - Draws headers and footers using `drawPageLayout` (which includes branding elements such as a logo, document date, and page number).

### Document Persistence

- **SavedPDF Model:**  
  Stores metadata for each saved PDF using SwiftData. Since SwiftData does not directly support URL types, the file path is stored as a string and then converted back to a URL when needed.

- **storePDF Function:**  
  Moves (or renames) the generated PDF file and saves a new `SavedPDF` record in the SwiftData context.

### User Interface Elements

- **DraggableBottomSheet:**  
  A custom SwiftUI view that enables a bottom sheet to be dragged up or down to reveal saved PDFs.

- **PDFViewer:**  
  Displays a PDF using the wrapped PDFKit view and shows debugging output (printing page contents to the console).

- **LottieViewRepresentable:**  
  Provides an animated loading indicator during model download or PDF generation.

## MLX Framework Integration

### Overview

The MLX framework (using MLXLLM and MLXLMCommon) abstracts interactions with large language models. It simplifies loading, configuring, and running inference on a model.

### Key Components

- **LLMModelFactory:**  
  Manages the asynchronous download and loading of the model container based on a provided configuration.

- **ModelRegistry:**  
  Contains preconfigured model definitions. For example, `ModelRegistry.llama3_2_1B_4bit` provides a setup for the Llama 3 model in a 4-bit quantized format.

- **MLXLMCommon.generate:**  
  Handles the inference process. It accepts prepared input and parameters, then returns generated tokens that can be decoded into text.

### Integration in Origo

Within the **Content_Camera_View** extension, the function `generate(structuredText:downloadProgress:)` leverages the MLX framework to:

1. **Load the Model Container:**  
   Using `LLMModelFactory.shared.loadContainer(configuration:)` with a specific configuration (from `ModelRegistry`), the model is loaded asynchronously. Download progress is communicated via a SwiftUI binding.

2. **Process Recognized Text:**  
   The function iterates over structured text sections. It sends a custom prompt to the model:
   - For titles: "Summarize this title while keeping it clear: ..."
   - For paragraphs: "Summarize this paragraph while preserving its structure: ..."
   
3. **Run Inference:**  
   The call to `MLXLMCommon.generate` runs the text generation, abstracting the low-level details of tokenization and decoding.

4. **Update the UI:**  
   Once the model processes the text, the output is aggregated and updated on the main thread via SwiftUI, ensuring a smooth user experience.

## Usage Instructions

1. **Launch the App:**  
   The welcome screen appears briefly, then the main camera view is displayed.
2. **Document Scanning:**  
   Tap the camera button to scan a document. The OCR process groups the text into structured blocks.
3. **Text Processing & LLM Integration:**  
   The scanned text is processed using the LLM model. If the scanned text matches a predefined liturgical text, it is transformed into a structured, formatted LIS-friendly version.
4. **PDF Generation & Preview:**  
   A PDF is generated from the processed text and can be previewed and saved. The PDF preview modal is non-interactively dismissible—it can only be closed via the cancel button.
5. **Document Management:**  
   Use the draggable bottom sheet to view and manage your saved documents.
