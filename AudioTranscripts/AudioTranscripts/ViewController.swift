//
//  ViewController.swift
//  AudioTranscripts
//
//  Created by Tecorb Technologies on 14/02/23.
//

import UIKit
import BMPlayer

class ViewController: UIViewController {
    /**
     It's defines the Custom player
     */
    @IBOutlet weak var player: BMCustomPlayer!
    
    @IBOutlet weak var textContent: UITextView!
    /**
     It's contains complete SRT Contents
     */
    var trancriptContent : String = ""
    
    /**
     Specify position of SRT file at index returning as string
     */
    var currentTextLocation :Int = 1
    /**
     Specify last position of SRT file at index returning as string
     */
    var previousTextLocation :Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playVideo()
    }
    
    
    //let video url = "http://baobab.wdjcdn.com/1456117847747a_x264.mp4"
    //big bunny url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    
    /// Function used to start player fromaudio or video player url as well as adding to SRT file with name into BMPlayer
    func playVideo(){
        let str = Bundle.main.url(forResource: "SubtitleDemo", withExtension: "srt")!
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        
        let subtitle = BMSubtitles(url: str)
        
        let asset = BMPlayerResource(name: "Big Buck Bunny",
                                     definitions: [BMPlayerResourceDefinition(url: url, definition: "480p")],
                                     cover: nil,
                                     subtitles: subtitle)
        /// Player start at specific time that is called seekBar
        player.seek(1)
        player.setVideo(resource: asset)
        player.delegate = self
        player.controlView.mainMaskView.isHidden = false
        player.controlView.delegate = self
      //  player.control
       // player.play()
        //changeButton.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.trancriptContent = self.textContent.text
        print(self.trancriptContent)
    }


}


/**
 It's specify the properties used in BMPlayer authorised properties manage and control the view of player, returning the string
 */
extension ViewController: BMPlayerDelegate, BMPlayerControlViewDelegate{
    
    func controlView(controlView: BMPlayerControlView, didChooseDefinition index: Int){
        print(index)
    }
    
    func controlView(controlView: BMPlayerControlView, didPressButton button: UIButton){
        print(controlView)
    }
   
    func controlView(controlView: BMPlayerControlView, slider: UISlider, onSliderEvent event: UIControl.Event){
        print(slider)
    }
     
    func controlView(controlView: BMPlayerControlView, didChangeVideoPlaybackRate rate: Float){
        print(rate)
    }
    
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print(state)
    }
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        print(totalDuration)
    }
    
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        let selectText = player.resource.subtitle?.search(for: currentTime)?.text
        if  let _ = self.trancriptContent.localizedStandardRange(of: selectText ?? ""){
            if selectText != ""{
                guard let textFound = selectText else {
                    return
                }
                self.loadTextInTableViewWithHighlighted(text: textFound)
            }
        }
     }
    
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        print(playing)
    }
    
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        print(isFullscreen)
    }
}

extension ViewController{
    /// This function used to find colored the background of highlighted text, This method contains the NSMutableAttributedString returning the location and length of Highlighted text.
    /// - Parameter text: input text behave as highlighted text on the basis of location and lenght.
    func loadTextInTableViewWithHighlighted(text:String){
        if text != ""{
            if let string = self.textContent.text, let range = string.localizedStandardRange(of: text) {
                if text != ""{
                    let viewRange = NSRange(range, in: string)
                    self.textContent.selectedRange = viewRange
                    self.currentTextLocation = self.textContent.selectedRange.location
                    let textSring = NSMutableAttributedString(string: trancriptContent)
                    if self.currentTextLocation >= self.previousTextLocation{
                        if UIDevice.current.userInterfaceIdiom == .pad{
                            textSring.setColorForText(text, with: .black)
                            textSring.addAttribute(.backgroundColor, value: UIColor(named: "#FFCFCF") ?? .orange, range: NSRange(location: self.currentTextLocation, length: text.count))
                            self.textContent.text = ""
                            self.textContent.attributedText = nil
                            self.textContent.attributedText = textSring
                            self.textContent.font = UIFont(name: "Roboto", size: 22.0)
                            self.textContent.textAlignment = .justified
                            self.previousTextLocation = self.currentTextLocation
                            self.textContent.scrollRangeToVisible(NSRange(location:viewRange.location, length:viewRange.length))
                        } else {
                            textSring.setColorForText(text, with: .black)
                            textSring.addAttribute(.backgroundColor, value: UIColor(named: "#FFCFCF") ?? .orange, range: NSRange(location: self.currentTextLocation, length: text.count))
                            self.textContent.text = ""
                            self.textContent.attributedText = nil
                            self.textContent.attributedText = textSring
                            self.textContent.font = UIFont(name: "Roboto", size: 16.0)
                            self.textContent.textAlignment = .justified
                            self.previousTextLocation = self.currentTextLocation
                            self.textContent.scrollRangeToVisible(viewRange)
                        }
                    }else{
                        self.textContent.textAlignment = .justified
                        var totlaTextLength:Int = 0
                        var curentTextLoc: Int = 0
                        let content : String = self.trancriptContent
                        let range = content.ranges(of: text)
                        for i in 0 ..< range.count{
                            if range[i].lowerBound.utf16Offset(in: content) > self.previousTextLocation{
                                totlaTextLength = range[i].upperBound.utf16Offset(in: content)-range[i].lowerBound.utf16Offset(in: content)
                                curentTextLoc = range[i].lowerBound.utf16Offset(in: content)
                                var seeRange = NSRange(location: curentTextLoc, length: totlaTextLength)
                                let getTextAtRange = textSring.attributedSubstring(from: seeRange)
                                let selectTetx = getTextAtRange.string
                                seeRange = (textSring.string as NSString).range(of: selectTetx, options: [], range: seeRange)
                                if (seeRange.location != NSNotFound) {
                                    textSring.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: seeRange.location, length: seeRange.length))
                                    textSring.addAttribute(.backgroundColor, value: UIColor(named: "#FFCFCF") ?? .blue, range: NSRange(location: seeRange.location, length: seeRange.length))
                                    seeRange = NSRange(location: seeRange.location + seeRange.length, length: textSring.string.count - (seeRange.location + seeRange.length))
                                    self.textContent.attributedText = textSring
                                    self.textContent.font = (UIDevice.current.userInterfaceIdiom == .pad) ? UIFont(name: "Roboto", size: 22.0) : UIFont(name: "Roboto", size: 16.0)
                                    self.textContent.textAlignment = .justified
                                    self.currentTextLocation = curentTextLoc
                                    break
                                }
                            }
                        }
                    }
                } else {
                }
            } else {
            }
        }
    }
}

extension NSMutableAttributedString{
    /// Mention The attributed string with font size
    /// - Parameters:
    ///   - textToFind: define the string that are return from SRT File
    ///   - color: specify the text color
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            var boldFont : UIFont = UIFont()
            boldFont = UIFont(name: "Helvetica Neue", size: 15)!
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
            addAttribute(NSAttributedString.Key.font, value: boldFont, range: range)
        }
    }
}
