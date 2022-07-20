//
//  DatePickerViewController.swift
//  MovieService
//
//  Created by 미미밍 on 2022/06/01.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBAction func selectDate(_ sender: UIDatePicker) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-mm-dd"
        print(dateformatter.string(from: sender.date))
        print(sender.date)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
