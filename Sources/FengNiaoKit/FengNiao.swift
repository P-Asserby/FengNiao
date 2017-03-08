//
//  FengNiao.swift
//  FengNiao
//
//  Created by WANG WEI on 2017/3/7.
//
//

import Foundation
import PathKit

enum FileType {
    case swift
    case objc
    case xib
    
    init?(ext: String) {
        switch ext {
        case "swift": self = .swift
        case "m", "mm": self = .objc
        case "xib", "storyboard": self = .xib
        default: return nil
        }
    }
    
    func searchRules(extensions: [String]) -> [FileSearchRule] {
        switch self {
        case .swift: return [SwiftImageSearchRule(extensions: extensions)]
        case .objc: return [ObjCImageSearchRule(extensions: extensions)]
        case .xib: return [XibImageSearchRule()]
        }
    }
}

public struct FileInfo {
    
}

public enum FengNiaoError: Error {
    case noResourceExtension
    case noFileExtension
}

public struct FengNiao {

    let projectPath: Path
    let excludedPaths: [Path]
    let resourceExtensions: [String]
    let searchInFileExtensions: [String]
    
    public init(projectPath: String, excludedPaths: [String], resourceExtensions: [String], searchInFileExtensions: [String]) {
        let path = Path(projectPath).absolute()
        self.projectPath = path
        self.excludedPaths = excludedPaths.map { path + Path($0) }
        self.resourceExtensions = resourceExtensions
        self.searchInFileExtensions = searchInFileExtensions
    }
    
    public func unusedFiles() throws -> [FileInfo] {
        guard !resourceExtensions.isEmpty else {
            throw FengNiaoError.noResourceExtension
        }
        guard !searchInFileExtensions.isEmpty else {
            throw FengNiaoError.noFileExtension
        }

        return [FileInfo()]
    }
    
    func allResourceFiles() -> [String: FileInfo] {
        
        
        return [:]
    }
    
    func allUsedStringNames() -> Set<String> {
        return usedStringNames(at: projectPath)
    }
    
    func usedStringNames(at path: Path) -> Set<String> {
        guard let subPaths = try? path.children() else {
            print("Failed to get contents in path: \(path)")
            return []
        }
        
        var result = [String]()
        for subPath in subPaths {
            if subPath.lastComponent.hasPrefix(".") {
                continue
            }
            
            if excludedPaths.contains(subPath) {
                continue
            }
            
            if subPath.isDirectory {
                result.append(contentsOf: usedStringNames(at: subPath))
            } else {
                let fileExt = subPath.extension ?? ""
                guard searchInFileExtensions.contains(fileExt) else {
                    continue
                }
                
                let fileType = FileType(ext: fileExt)
                
                let searchRules = fileType?.searchRules(extensions: resourceExtensions) ??
                                  [PlainImageSearchRule(extensions: resourceExtensions)]
                
                let content = (try? subPath.read()) ?? ""
                result.append(contentsOf: searchRules.flatMap { $0.search(in: content) })
            }
        }
        
        return Set(result)
    }
}




