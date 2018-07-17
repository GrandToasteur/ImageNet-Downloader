//
//  ViewController.swift
//  ImageNet Downloader
//
//  Created by Onoulade on 01/07/2018.
//  Copyright © 2018 Dadu Prod. All rights reserved.
//

import Cocoa
import Vision

class ViewController: NSViewController, URLSessionDownloadDelegate {
    

    @IBOutlet weak var labelTextField: NSTextField!
    @IBOutlet weak var inputField: NSTextField!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var imagePreview: NSImageView!
    @IBOutlet weak var downloadProgress: NSProgressIndicator!
    @IBOutlet weak var progressionLabel: NSTextField!
    @IBOutlet weak var progressionCircle: NSProgressIndicator!
    @IBOutlet weak var nbOfImagesLabel: NSTextField!
    @IBOutlet weak var nbBlankLabel: NSTextField!
    @IBOutlet weak var nbErrorsLabel: NSTextField!
    @IBOutlet weak var nbToDownload: NSTextField!
    @IBOutlet weak var pathLabel: NSTextField!
    @IBOutlet weak var rightView: NSView!
    
    @IBAction func updateLabels(_ sender: Any) {
        getUrlsFromInputField()
        nbToDownload.stringValue = String(urls.count)
        displayInfo()
        checkIfWeCanDown()
    }
    
    @IBAction func chooseDirectory(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a folder"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = []
        
        if (dialog.runModal() == .OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                print(result)
                let path = result!.path
                savePath = path
                displayFullPath()
                checkIfWeCanDown()
            }
        } else {
            // User clicked on "Cancel"
            checkIfWeCanDown()
            return
        }
    }
    @IBAction func setLabelDown(_ sender: Any) {
        saveLabel = labelTextField.stringValue
        displayFullPath()
        checkIfWeCanDown()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        startDownloading()
    }
    
    var urls:[URL] = []
    var savePath = ""
    var saveLabel = ""
    var actualDownloadIndex = 0
    var nbDownload = 100
    var nbErrors = 0
    var  nbBlank = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEmptyScene()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func setEmptyScene() {
        downloadProgress.alphaValue = 0
        progressionLabel.stringValue = ""
        progressionCircle.alphaValue = 0
        nbOfImagesLabel.stringValue = ""
        nbErrorsLabel.stringValue = ""
        nbBlankLabel.stringValue = ""
        
        pathLabel.stringValue = "No folder choosen"
        checkIfWeCanDown()
    }
    
    func checkIfWeCanDown() {
        sendButton.isEnabled = false
        
        if urls.count == 0 {
            print("no urls in list")
            return
        }
        
        if savePath == "" {
            print("no save path")
            return
        }
        
        if saveLabel == "" {
            print("no save label")
            return
        }
        
        if nbDownload > 0 && nbDownload >= urls.count {
            print("incoherent download number")
            return
        }
        
        sendButton.isEnabled = true
    }
    
    func getUrlsFromInputField() {
        urls = []
        let urlsString = inputField.stringValue.components(separatedBy: "\n")
        
        for url in urlsString {
            if let urlVar = URL(string: url) {
                urls.append(urlVar)
            }
        }
        
    }
    
    func displayFullPath() {
        var l = savePath
        
        if l == "" {
            return
        }
        
        if labelTextField.stringValue != nil {
            l += "/" + labelTextField.stringValue
        }
        pathLabel.stringValue = l
    }
    
    func displayInfo() {
        let nbUrls = String(urls.count)
        
        let informations = "Urls : " + nbUrls
        
        nbOfImagesLabel.stringValue = informations
    }
    
    func displayErrors() {
        let informations = "Errors : " + String(nbErrors)
        
        nbErrorsLabel.stringValue = informations
    }
    
    func displayBlank() {
        let informations = "Empty : " + String(nbBlank)
        
        nbBlankLabel.stringValue = informations
    }
    
    func startDownloading() {
        if savePath == "" || urls.count == 0 || saveLabel == "" {
            return
        }
        
        let toDownloadInt = Int(self.nbToDownload.stringValue)
        
        if toDownloadInt != nil  {
            nbDownload = toDownloadInt!
        }
        else {
            nbDownload = urls.count
        }
        
        if urls.count < nbDownload {
            return
        }
        else {
            urls.shuffle()
        }
        
        actualDownloadIndex = 0
        
        
        if createPath() {
            nbErrors = 0
            nbBlank = 0
            
            displayErrors()
            displayBlank()
            downloadProgress.alphaValue = 1
            progressionCircle.alphaValue = 1
            download()
        }
        
    }
    
    func callBackDownload() {
        if actualDownloadIndex >= nbDownload {
            return
        }
        actualDownloadIndex += 1
        
        let pctDone:Double = Double(actualDownloadIndex) / Double(nbDownload) * 100
        let displayString = "Downloaded : \(actualDownloadIndex) / \(nbDownload)"
        
        DispatchQueue.main.async {
            self.progressionCircle.doubleValue = pctDone
            self.progressionLabel.stringValue = displayString
        }
        
        if actualDownloadIndex >= urls.count {
            print("finished")
            return
        }
        else {
            download()
        }
    }
    
    func download() {
        print("start download")
        if actualDownloadIndex >= urls.count {
            return
        }
        let toDownload = urls[actualDownloadIndex]
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: toDownload)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
         print("download task did write data")
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100
        print(progress)
        DispatchQueue.main.async {
            self.downloadProgress.doubleValue = progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let uuid = UUID().uuidString
        
        let originalUrl = urls[actualDownloadIndex].absoluteString
        
        let pathDD:NSString = originalUrl as NSString
        let ext = pathDD.pathExtension
        
        let filename = uuid + "." + ext
        
        let fileManager = FileManager.default
        let copyPath = savePath + "/" + saveLabel + "/" + filename
        
        print(copyPath)
        
        do {
            try fileManager.moveItem(atPath: location.path, toPath: copyPath)
            let image = NSImage(contentsOf: URL(fileURLWithPath: copyPath))
            if image?.isValid == true {
                
                if #available(OSX 10.13, *) {
                    isImageBlank(copyPath)
                } 
                DispatchQueue.main.async {
                    self.imagePreview.image = image
                }
            }
            else {
                DispatchQueue.main.async {
                    self.nbErrors += 1
                    self.displayErrors()
                    self.deleteFile(copyPath)
                }
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        deleteFile(location.path)
        
        
        
        callBackDownload()
    }
    
    func deleteFile(_ path : String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    @available(OSX 10.13, *)
    func isImageBlank(_ path: String) {
        let image = NSImage(contentsOfFile: path)
        let imageSize = image!.size
        var frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        let cgImage = image?.cgImage(forProposedRect: &frame, context: nil, hints: nil)
        let ciImage = CIImage(cgImage: cgImage!)
        let orientation = CGImagePropertyOrientation.down
        
        do {
            let model = try VNCoreMLModel(for: ImageClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error, path: path)
            })
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            try handler.perform([request])
            
        }
        catch {
            print(error)
        }
    }
    
    @available(OSX 10.13, *)
    func processClassifications(for request: VNRequest, error: Error?, path: String) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            if classifications.count > 0 {
                let mostProbably = classifications[0].identifier
                if mostProbably == "blank" {
                    self.nbBlank += 1
                    self.displayBlank()
                    self.deleteFile(path)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("error with the url request, pass this instance")
        if error != nil {
            callBackDownload()
        }
    }
    
    func createPath() -> Bool {
        let folderPath = savePath + "/" + saveLabel + "/"
        let manager = FileManager.default
        do {
            try manager.createDirectory(atPath:folderPath,
                                    withIntermediateDirectories:true,  attributes:nil)
            //self.savePath = folderPath
            return true
        }
        catch {
            print("failed to create folder at path : " + folderPath)
            print(error)
            return false
        }
        
    }
}

