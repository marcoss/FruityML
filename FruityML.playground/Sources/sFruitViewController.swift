//import UIKit
//import PlaygroundSupport
//
//
//@objc(FruitViewController)
//public class FruitViewController : UIViewController {
//    @IBOutlet weak var sunImageView: UIImageView!
//    @IBOutlet weak var eyesImageView: UIImageView!
//
//    @IBOutlet weak var messageLabel: UILabel!
//    
//    override public func viewDidLoad() {
//        rotateSun()
//        super.viewDidLoad()
//    }
//    
//    public func rotateSun() {
//        UIView.animate(withDuration: 5.0, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
//            self.sunImageView.transform = self.sunImageView.transform.rotated(by: CGFloat(Double.pi))
//        }) { completed in
//            self.rotateSun()
//        }
//    }
//    
//    override public func loadView() {
//        print("I WORKED")
//
//        // This is important to call UIViewController
//        super.loadView()
//        
//        //        let view = UIView()
//        //        view.backgroundColor = UIColor(red: 40/255, green: 175/255, blue: 180/255, alpha: 1.0)
//        //
//        //        let label = UILabel()
//        //        label.backgroundColor = UIColor.red
//        //        label.frame = CGRect(x: 0, y: 200, width: 100, height: 20)
//        //        label.text = "I'm Bob, I can read fruit."
//        //        label.font = UIFont.systemFont(ofSize: 20.0, weight: .black)
//        //        label.textAlignment = .center
//        //        label.textColor = .white
//        //
//        //        view.addSubview(label)
//        //        self.view = view
//    }
//}
//
