//
//  SavedPDF_Model.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 06/03/25.


import SwiftData
import PDFKit
import SwiftUI

@Model // Marks this class as a SwiftData model, allowing it to be stored in a database
class SavedPDF {
    @Attribute(.unique) var id: UUID //The @Attribute(.unique) ensures that each PDF has a distinct UUID.
    var fileName: String
    var filePathString: String //Stores the file path as a string instead of a URL (SwiftData does not support URL directly)
    var dateCreated: Date

    var filePath: URL {
        return URL(fileURLWithPath: filePathString)
    } //Converting the filepath into an URL for being able to use it with PDFkit that requires an URL type

    
    init(fileName: String, filePath: URL) {
        self.id = UUID()
        self.fileName = fileName
        self.filePathString = filePath.path //The path, or an empty string if the URL has an empty path.
        self.dateCreated = Date()
    } //Initializer
}








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
        print("✅ PDF generated at: \(pdfURL.path)")
        return pdfURL
    } catch {
        print("❌ Failed to generate PDF: \(error)")
        return nil
    }
}

// Inserts the PDF metadata into SwiftData.
func storePDF(url: URL, fileName: String, context: ModelContext) {
    // Create a sanitized file name
    let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
    let newFileName = trimmedName.isEmpty ? url.lastPathComponent : trimmedName
    
    // Get the documents directory
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return
    }
    
    // Create a new file URL with the custom name
    let newURL = documentsDirectory.appendingPathComponent(newFileName)
    
    do {
        // Move the file to the new URL, effectively renaming it.
        try FileManager.default.moveItem(at: url, to: newURL)
        
        // Create and store your PDF model with the new URL and custom name.
        let savedPDF = SavedPDF(fileName: newFileName, filePath: newURL)
        context.insert(savedPDF)
        print("PDF saved with custom name: \(newFileName)")
    } catch {
        print("Error renaming PDF: \(error)")
    }
}




//TUTORIAL

/*
func saveAsPDF(text: String, context: ModelContext) { //context: ModelContext → The SwiftData database context, used to save PDF metadata.
    
    let fileName = "ScannedText_\(UUID().uuidString).pdf" // <-- Generated from the app, NEEDS TO BE CHANGED!!
    
    
    let pdfURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
    /*
     
     1) FileManager = FileManager is a built-in class in Swift that manages the file system, .default is a shared instance of FileManager
     
     2) .urls(for: , in: ) = This retrieves an array of URLs for the Documents directory in the app’s sandbox,
     
     -->  .documentDirectory = Refers to the Documents Folder inside the app's private storage
     --> .userDomainMask = Refers to the user's personal app space.
     
     Example:
     ["file:///var/mobile/Containers/Data/Application/ABCD1234/Documents/"]
     
     User Domain: /var/mobile/Containers/Data/Application/ABCD1234/, referes to the ENTIRE storage of the app, it's PRIVATE to the app
     
     Document Directory: /Documents/ , the specific location where to save files
     
     This structure ensures that the PDF files are saved inside the app and doesn't interfere with the system files
     
     
     3) .first! = The function returns an array of URLs (even though it usually contains only one).
     The ! (force unwrap) assumes that there is always a valid directory returned.
     
     
     4) .appendingPathComponent(fileName) = This adds the file name (e.g., "ScannedText_123.pdf") to the directory path.
     It ensures that the final URL points to the actual PDF file inside the Documents folder.
     
     Example:
     file:///var/mobile/Containers/Data/Application/ABCD1234/Documents/ScannedText_123.pdf
     
     */
    
    
    
    
    
    
    let format = UIGraphicsPDFRendererFormat()
    
    /*
     Creates a PDF format object that defines settings for how the PDF will be rendered.
     
     UIGraphicsPDFRendererFormat() allows you to customize the PDF settings, by DEFAULT is EMPTY
     
     We can add metadata (title, author, encryption, etc.), by modifying format.documentInfo.
     
     Like this:
     
     format.documentInfo = [
     kCGPDFContextTitle as String: "My Custom PDF",
     kCGPDFContextAuthor as String: "Francesco Silvestro"
     ]
     
     */
    
    
    
    
    
    
    
    
    
    
    
    let pageSize = CGSize(width: 612, height: 792)
    /*
     CGSize is a Core Graphics structure used in Swift to define width and height measurements.
     
     Sets the size of each PDF page.
     
     CGSize(width: 612, height: 792) defines the dimensions of the PDF page in points (not pixels).
     This is equal to an A4 size.
     
     */
    
    
    
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
    
    /*
     
     UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
     
     1) bounds: CGRect(origin: .zero, size: pageSize) → Defines the dimensions of each page.
     
     2) format: format → Uses the PDF format settings from before.
     
     
     It defines the paper size and it prepares the environment for rendering text and images.
     
     
     
     */
    
    do {
        try renderer.writePDF(to: pdfURL, withActions: { context in
            
            /*
             We use DO-TRY for the error handling, like not enough storage etc.
             
             renderr.writePDF = creates and writes a PDF file using UIGraphicsPDFRenderer
             
             1) It creates a new PDF file at the location pdfURL.
             
             2) The closure ({ context in ... }) contains all the PDF content (text, images, etc.).
             
             3) Everything inside { context in ... } is executed while the PDF is being created.
             */
            
            
            context.beginPage()
            /*
             
             Starts a new page inside the PDF, and if the PDF has multiple pages, we call beginPage() again for each new page
             
             */
            
            
            
            
            let textRect = CGRect(x: 20, y: 20, width: pageSize.width - 40, height: pageSize.height - 40)
            
            /*
             
             This defines a rectangular area (textRect) where the text will be drawn inside the PDF page.
             
             The text starts at (20,20) points from the top-left corner of the page, a 20 margin ensures that the text doesn't go against the edges
             
             pageSize.width is the full width of the PDF page (e.g., 612 points for an A4 page).
             
             pageSize.height is the full height of the PDF page (e.g., 792 points for an A4 page). -->Doesn't touch the corners
             
             
             EXAMPLE:
             
             +----------------------------------------------------+
             | (20,20)                                          |
             |   +------------------------------------------+    |
             |   |                                          |    |
             |   |   Text will be drawn inside this box     |    |
             |   |                                          |    |
             |   +------------------------------------------+    |
             |                                                 |
             +----------------------------------------------------+
             
             
             */
            
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            /*
             
             1) let paragraphStyle = NSMutableParagraphStyle()
             
             Creates a mutable paragraph style object, NSMutableParagraphStyle is used to control how text is formatted and aligned.
             
             There is also the object NSParagraphStyle that cannot be modified
             
             
             2) paragraphStyle.alignment = .left --> Aligns the text to the left.
             
             
             OTHER Possible values:
             
             Value    Effect
             .left    Text aligns to the left (default).
             .right    Text aligns to the right.
             .center    Text is centered in the text box.
             .justified    Text is evenly spaced like a newspaper.
             .natural    Uses the default text direction (left-to-right for English).
             
             
             
             3) paragraphStyle.lineBreakMode = .byWordWrapping
             
             Determines how text wraps when it reaches the end of the line.
             
             --> .lineBreakMode controls how text breaks when it doesn’t fit inside the text box.
             
             --> .byWordWrapping ensures text wraps at word boundaries (doesn’t cut words in half).
             
             OTHER Possible values:
             
             Value    Effect
             .byWordWrapping    Default. Wraps at word boundaries.
             
             .byCharWrapping    Wraps character by character (used for non-Latin scripts).
             
             .byClipping    Cuts off text at the edge (no wrapping).
             
             .byTruncatingTail    Adds ... at the end if the text is too long.
             
             .byTruncatingMiddle    Cuts text in the middle with ....
             
             .byTruncatingHead    Cuts text at the beginning with ....
             
             
             
             
             
             
             
             
             
             
             
             
             */
            
            
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraphStyle
            ]
            
            /*
             
             Creates a dictionary of text styling options.
             
             ! Dictionary is a type !
             
             The dictionary keys are NSAttributedString.Key, which defines how the text looks, the values control the font, alignment, spacing, etc.
             
             
             
             -->  .font    Sets the font and size (e.g., UIFont.systemFont(ofSize: 16))
             
             -->   .paragraphStyle    Applies alignment and line breaking rules (defined before).
             
             
             */
            
            
            
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            
            /*
             
             
             Creates an attributed string (formatted text).
             
             This ensures text rendering includes font, alignment, and spacing.
             
             Without NSAttributedString, text would be drawn in default settings (basic, unstyled).
             
             
             */
            
            
            
            let textStorage = NSTextStorage(attributedString: attributedText)
            /*
             
             Stores the formatted text (NSAttributedString) in an object that can be laid out and drawn.
             
             --> NSTextStorage is a container for styled text that can dynamically update as the layout changes.
             We are passing the attributedText created before
             
             It works with NSLayoutManager to handle text rendering and pagination. --> Next line of code
             
             
             */
            
            let layoutManager = NSLayoutManager()
            /*
             
             Manages the layout of text characters (glyphs) across lines and pages.
             
             It takes the text from NSTextStorage and flows it through the text container.
             
             It ensures proper word wrapping and line breaking.
             
             */
            
            let textContainer = NSTextContainer(size: textRect.size)
            textContainer.lineBreakMode = .byWordWrapping
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            
            /*
             
             Defines the area where text is displayed.
             
             1) NSTextContainer(size: textRect.size) → Specifies the width and height available for text.
             
             2) textContainer.lineBreakMode = .byWordWrapping → Ensures words don’t get cut off.
             
             Connects everything together:
             
             3) layoutManager.addTextContainer(textContainer) → Adds the text container to the layout manager.
             
             4) textStorage.addLayoutManager(layoutManager) → Links text storage with the layout manager.
             
             
             RECAP:
             
             1) NSTextStorage holds the text.
             
             2) NSLayoutManager calculates how to fit text into available space.
             
             3) NSTextContainer defines the physical space where text can be drawn.
             
             
             
             
             
             
             
             
             
             
             */
            
            
            
            
            var range = NSRange(location: 0, length: textStorage.length)
            var currentPage = 1
            /*
             
             Defines the starting position (range.location) and the total length of text.
             
             */
            
            while range.location < textStorage.length {
                /*
                 
                 Keeps running as long as there is more text to process.
                 
                 1) textStorage.length → Total number of characters in the text.
                 
                 2) range.location → The current character position being drawn.
                 
                 */
                
                let textHeight = layoutManager.usedRect(for: textContainer).height
                
                /*
                 
                 Calculates the height of the text that fits in the text container.
                 
                 1) layoutManager.usedRect(for: textContainer).height tells us how much space the text is taking.
                 This helps determine if more text needs to be drawn on another page.
                 
                 If the text height exceeds the available space, we start a new page.
                 
                 
                 */
                
                if range.location > 0 {
                    context.beginPage() // Start a new page if needed
                }
                
                /*
                 Checks if we are on a new page and starts a new one if necessary.
                 
                 First page doesn’t need beginPage() because it’s already open.
                 
                 Any subsequent page must call context.beginPage() to create a new blank page.
                 
                 
                 */
                
                let drawingPoint = CGPoint(x: textRect.origin.x, y: textRect.origin.y)
                /*
                 Defines where the text should be drawn on the page.
                 
                 We are passing the TEXT CANVA made before
                 
                 */
                
                
                layoutManager.drawGlyphs(forGlyphRange: range, at: drawingPoint)
                
                /*
                 
                 Draws the current portion of text inside the PDF.
                 
                 1) layoutManager.drawGlyphs(...) renders the text on the page.
                 
                 2) forGlyphRange: range → Specifies which part of the text to draw.
                 
                 3) at: drawingPoint → Places the text at the correct position.
                 
                 */
                
                range.location += range.length
                
                /*
                 
                 Moves to the next portion of text that hasn’t been drawn.
                 
                 1) range.length holds the number of characters drawn on this page.
                 
                 2) range.location moves forward to the next part of the text.
                 
                 
                 */
                
                range.length = textStorage.length - range.location
                
                /*
                 
                 Calculates how much text is left to draw.
                 
                 Subtracts the text we already processed from the total text length.
                 
                 This ensures that we don't re-write the text
                 
                 
                 */
                
                currentPage += 1
                
                /*
                 
                 Tracks how many pages have been processed.
                 
                 !! WE CAN USE THIS TO DISPLAY THE PAGE NUMBER !!
                 
                 */
            }
        })
        
        // Save to SwiftData
        let newPDF = SavedPDF(fileName: fileName, filePath: pdfURL) //Creates the PDF Object
        context.insert(newPDF) //Insert it into SwiftData database
        
        //With the previous steps we have created the pdf, now we are creating a SavePDF object to pass inside the swiftData database
        
        
        print("✅ PDF saved successfully at: \(pdfURL.path)")
        print("✅ PDF metadata saved in SwiftData: \(newPDF.fileName)")
        
    } catch {
        print("❌ Failed to create PDF: \(error)")
    }
}
*/




import UIKit
import CoreText

/// Classifies text as a *Title* or *Body* based on heuristics
func classifyText(_ text: String) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
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

/// Determines if the text is likely a title
func isLikelyTitle(_ text: String) -> Bool {
    return text.count < 50 && text == text.uppercased()
}


/// Generates a PDF with formatted text (Titles & Body text)
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
            
            let formattedText = classifyText(text) // Apply formatting
            formattedText.draw(in: textRect)
        })
        print("✅ Styled PDF generated at: \(pdfURL.path)")
        return pdfURL
    } catch {
        print("❌ Failed to generate PDF: \(error)")
        return nil
    }
}


func generateStructuredPDF(textSections: [(text: String, isTitle: Bool)]) -> URL? {
    let fileName = "Structured_Scanned_Document_\(UUID().uuidString).pdf"
    let pdfURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        .appendingPathComponent(fileName)
    
    let format = UIGraphicsPDFRendererFormat()
    let pageSize = CGSize(width: 612, height: 792)  // Standard A4 dimensions
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
    
    do {
        try renderer.writePDF(to: pdfURL, withActions: { pdfContext in
            pdfContext.beginPage()
            
            var yOffset: CGFloat = 20
            let xOffset: CGFloat = 20
            let maxWidth: CGFloat = pageSize.width - 40
            let spacingAfterBlock: CGFloat = 10
            let spacingBetweenTitleAndBody: CGFloat = 5
            
            var i = 0
            while i < textSections.count {
                // When a title is immediately followed by a body, combine them.
                if i < textSections.count - 1 && textSections[i].isTitle && !textSections[i+1].isTitle {
                    let combinedAttributedString = NSMutableAttributedString()
                    
                    // Title attributes.
                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 22),
                        .paragraphStyle: {
                            let ps = NSMutableParagraphStyle()
                            ps.alignment = .left
                            ps.lineBreakMode = .byWordWrapping
                            return ps
                        }()
                    ]
                    // Body attributes.
                    let bodyAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 16),
                        .paragraphStyle: {
                            let ps = NSMutableParagraphStyle()
                            ps.alignment = .left
                            ps.lineBreakMode = .byWordWrapping
                            return ps
                        }()
                    ]
                    
                    let titleText = textSections[i].text.trimmingCharacters(in: .whitespacesAndNewlines)
                    let bodyText = textSections[i+1].text.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let titleAttrStr = NSAttributedString(string: titleText + "\n", attributes: titleAttributes)
                    let bodyAttrStr = NSAttributedString(string: bodyText, attributes: bodyAttributes)
                    
                    combinedAttributedString.append(titleAttrStr)
                    combinedAttributedString.append(bodyAttrStr)
                    
                    let constraintRect = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                    let combinedBounding = combinedAttributedString.boundingRect(with: constraintRect,
                                                                                 options: .usesLineFragmentOrigin,
                                                                                 context: nil)
                    let combinedHeight = ceil(combinedBounding.height)
                    
                    // If there isn't enough space in the current page, start a new page.
                    if yOffset + combinedHeight > pageSize.height - 20 {
                        pdfContext.beginPage()
                        yOffset = 20
                    }
                    
                    // If the combined block is too tall to fit even on an empty page,
                    // scale it down to fit.
                    if combinedHeight > pageSize.height - 40 {
                        let availableHeight = pageSize.height - 40
                        let scaleFactor = availableHeight / combinedHeight
                        pdfContext.cgContext.saveGState()
                        // Translate to drawing position.
                        pdfContext.cgContext.translateBy(x: xOffset, y: yOffset)
                        pdfContext.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)
                        // Draw at (0,0) since we've translated.
                        combinedAttributedString.draw(in: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: maxWidth / scaleFactor,
                                                                   height: combinedHeight))
                        pdfContext.cgContext.restoreGState()
                        yOffset += availableHeight + spacingAfterBlock
                    } else {
                        let drawRect = CGRect(x: xOffset, y: yOffset, width: maxWidth, height: combinedHeight)
                        combinedAttributedString.draw(in: drawRect)
                        yOffset += combinedHeight + spacingAfterBlock
                    }
                    
                    i += 2  // Skip the next block (already merged).
                } else {
                    // Process single block.
                    let block = textSections[i]
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: block.isTitle ? UIFont.boldSystemFont(ofSize: 22) : UIFont.systemFont(ofSize: 16),
                        .paragraphStyle: {
                            let ps = NSMutableParagraphStyle()
                            ps.alignment = .left
                            ps.lineBreakMode = .byWordWrapping
                            return ps
                        }()
                    ]
                    
                    let attrStr = NSAttributedString(string: block.text, attributes: attributes)
                    let constraintRect = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                    let bounding = attrStr.boundingRect(with: constraintRect,
                                                        options: .usesLineFragmentOrigin,
                                                        context: nil)
                    let requiredHeight = ceil(bounding.height)
                    
                    if yOffset + requiredHeight + spacingAfterBlock > pageSize.height - 20 {
                        pdfContext.beginPage()
                        yOffset = 20
                    }
                    
                    let textRect = CGRect(x: xOffset, y: yOffset, width: maxWidth, height: requiredHeight)
                    attrStr.draw(in: textRect)
                    yOffset += requiredHeight + spacingAfterBlock
                    i += 1
                }
            }
        })
        print("✅ Structured PDF generated at: \(pdfURL.path)")
        return pdfURL
    } catch {
        print("❌ Failed to generate PDF: \(error)")
        return nil
    }
}
