//
//  ViewController.swift
//  aubioDemo
//
//  Created by lls on 2018/7/31.
//  Copyright © 2018年 demo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let audioPath = Bundle.main.path(forResource: "audio", ofType: "wav"),
            let sweetDream = Bundle.main.path(forResource: "sweet_dream", ofType: "wav"),
        let nezha = Bundle.main.path(forResource: "nezha", ofType: "wav")
            else {
                return
            }
        DispatchQueue(label: "audio").async {
            testAudio(path: audioPath, hopSize: 512, sampleRate: 512)
            testAudio(path: sweetDream, hopSize: 512, sampleRate: 512)
            testAudio(path: nezha, hopSize: 512, sampleRate: 512)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

