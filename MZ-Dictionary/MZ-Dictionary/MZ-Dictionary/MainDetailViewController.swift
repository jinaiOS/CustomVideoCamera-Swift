//
//  MainDetailViewController.swift
//  MZ-Dictionary
//
//  Created by 김지은 on 2023/11/14.
//

import UIKit

class MainDetailViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    var dataArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = dataArray[0]
        lblContent.text = dataArray[1]
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
