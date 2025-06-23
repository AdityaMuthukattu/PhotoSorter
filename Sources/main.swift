import Foundation
import ArgumentParser

struct PhotoSorter: ParsableCommand {
	@Option(name: [.customShort("s"), .long], help: "Source directory path.")
    var source: String

    @Option(name: [.customShort("d"), .long], help: "Destination directory path.")
    var destination: String

    @Option(name: [.customShort("t"), .long], help: "Finder tag to match.")
    var tag: String
    
    @Flag(name: .long, help: "Copy files instead of moving.")
	var copy: Bool = false
    
    @Flag(name: .long, help: "Preview files to be moved without making changes.")
	var dryRun: Bool = false

    
    func run() throws {
    
    	let sourceURL = URL(fileURLWithPath: source)
        let destinationURL = URL(fileURLWithPath: destination)
        
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: sourceURL.path, isDirectory: nil) else {
            throw ValidationError("Source directory doesn't exist.")
        }
        
        do {
            try fm.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        } catch {
            throw ValidationError("Failed to create destination directory: \(error.localizedDescription)")
        }

        let contents = try fm.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: [.tagNamesKey], options: [.skipsHiddenFiles])

        for file in contents {
            if fileHasTag(file, tag: tag) {
                moveFile(file, to: destinationURL)

                if let rawFile = findMatchingRAW(for: file, in: sourceURL) {
                    moveFile(rawFile, to: destinationURL)
                } else {
                    print("No RAW match for: \(file.lastPathComponent)")
                }
            }
        }
        
        
        
    }
    
    
    func fileHasTag(_ url: URL, tag: String) -> Bool {
        guard let resourceValues = try? url.resourceValues(forKeys: [.tagNamesKey]),
              let tags = resourceValues.tagNames else {
            return false
        }
        return tags.contains(tag)
    }
    
    
    func findMatchingRAW(for imageURL: URL, in directory: URL) -> URL? {
        let baseName = imageURL.deletingPathExtension().lastPathComponent
        let rawExtensions = ["CR2", "NEF", "ARW", "RAF", "RW2", "ORF", "DNG"]

        for ext in rawExtensions {
            let rawURL = directory.appendingPathComponent(baseName).appendingPathExtension(ext)
            if FileManager.default.fileExists(atPath: rawURL.path) {
                return rawURL
            }
        }
        return nil
    }
    
    
    func moveFile(_ fileURL: URL, to destinationDir: URL) {
		let destinationURL = destinationDir.appendingPathComponent(fileURL.lastPathComponent)
		
		if dryRun {
			print("[Dry Run] Would \(copy ? "copy" : "move"): \(fileURL.path) → \(destinationURL.path)")
			return
		}
		
		let fm = FileManager.default
		
		do {
			if copy {
				// If file exists at destination, remove it first to avoid copy error
				if fm.fileExists(atPath: destinationURL.path) {
					try fm.removeItem(at: destinationURL)
				}
				try fm.copyItem(at: fileURL, to: destinationURL)
				print("Copied: \(fileURL.lastPathComponent)")
			} else {
				try fm.moveItem(at: fileURL, to: destinationURL)
				print("Moved: \(fileURL.lastPathComponent)")
			}
		} catch {
			print("Error \(copy ? "copying" : "moving") \(fileURL.lastPathComponent): \(error.localizedDescription)")
		}
	}
}

PhotoSorter.main()
