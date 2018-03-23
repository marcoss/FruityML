//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

@objc(FruitViewController)
public class FruitViewController : UIViewController {
    @IBOutlet weak var sunImageView: UIImageView!
    @IBOutlet weak var eyesImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // When an intro message is fully played out
    var hasWelcomedUser = false
    
    // View will appear
    public override func viewDidLoad() {
        sunImageView.layer.opacity = 0.0
        eyesImageView.layer.opacity = 0.0
        messageLabel.alpha = 0.0
    }
    
    // View did appear
    public override func viewDidAppear(_ animated: Bool) {
        createView()
        super.viewDidAppear(animated)
    }
    
    // Load the sun
    public func createView() {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.sunImageView.layer.opacity = 1.0
            self.eyesImageView.layer.opacity = 1.0
        })
        
        // Start rotating the sun
        rotateSun()
        
        // Start to welcome user
        startWelcome()
    }
    
    // Start messages
    public func startWelcome() {
        sayMessage(message: "Hello human! I'm the Sun, grower of all tasty fruits on your planet Earth.", seconds: 2.5)
        sayMessage(message: "I can tell you about different fruits you send me.", seconds: 7.0)
        sayMessage(message: "Use your Earth goggles, I mean camera, to send me a fruit.", seconds: 12.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 + 7.0 + 12.0) {
            self.hasWelcomedUser = true
        }
    }
    
    // Say message
    public func sayMessage(message: String, seconds: Double) {
        // Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            print("Has welcomed user = \(self.hasWelcomedUser)")
            // Fade out
            UIView.animate(withDuration: 1.0, animations: {
                self.messageLabel.alpha = 0.0
            })
            
            // Replace label
            self.messageLabel.text = message
            
            // Fade in
            UIView.animate(withDuration: 0.5, animations: {
                self.messageLabel.alpha = 1.0
            })
        }
    }
    
    // Rotate sun
    public func rotateSun() {
        UIView.animate(withDuration: 5.0, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.sunImageView.transform = self.sunImageView.transform.rotated(by: CGFloat(Double.pi))
        }) { completed in
            self.rotateSun()
        }
    }
    
    // Load view
    override public func loadView() {
        // This is important to call UIViewController
        super.loadView()
        
        //        let view = UIView()
        //        view.backgroundColor = UIColor(red: 40/255, green: 175/255, blue: 180/255, alpha: 1.0)
        //
        //        let label = UILabel()
        //        label.backgroundColor = UIColor.red
        //        label.frame = CGRect(x: 0, y: 200, width: 100, height: 20)
        //        label.text = ""
        //        label.font = UIFont.systemFont(ofSize: 20.0, weight: .black)
        //        label.textAlignment = .center
        //        label.textColor = .white
        //
        //        view.addSubview(label)
        //        self.view = view
    }
}

let storyboard = UIStoryboard(name: "Main", bundle: nil)
let view = storyboard.instantiateViewController(withIdentifier: "MainView") as! FruitViewController

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = view

