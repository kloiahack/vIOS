//
//  CreateNewWallet.swift
//  VergeiOSUITests
//
//  Created by Swen van Zanten on 09-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest

class CreateNewWallet: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateNewWallet() {
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        
        // Tap the create wallet button
        XCTAssert(app.buttons["Create a new wallet"].exists)
        app.buttons["Create a new wallet"].tap()
        
        _ = app.wait(for: .runningForeground, timeout: 1)
        
        XCTAssert(app.navigationBars["Set wallet PIN"].exists)
        app.navigationBars["Set wallet PIN"].buttons.element(boundBy: 1).tap()
        app.sheets["Choose a PIN size"].buttons["4 Digits"].tap()
        
        _ = app.wait(for: .runningForeground, timeout: 1)
        
        // Fill in the app code
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        
        _ = app.wait(for: .runningForeground, timeout: 1)
        
        // Confirm the app code
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        
        _ = app.wait(for: .runningForeground, timeout: 1)
        
        app.buttons["Proceed"].tap()
        app.buttons["Write down paper key"].tap()

        _ = app.wait(for: .runningForeground, timeout: 1)

        var words: [String] = []
        for i in 1...12 {
            words.append(app.staticTexts["word"].label)
            
            if i == 12 {
                app.buttons["Done"].tap()
            } else {
                app.buttons["Next"].tap()
            }
        }
        
        // Words
        let firstWordLabel: String = app.staticTexts["firstWord"].label.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
        let secondWordLabel: String = app.staticTexts["secondWord"].label.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
        
        let firstTextField = app.textFields["firstWordTextfield"]
        firstTextField.tap()
        firstTextField.typeText(words[Int(firstWordLabel)! - 1])
        firstTextField.typeText("\n")
        
        let secondTextField = app.textFields["secondWordTextfield"]
        secondTextField.tap()
        secondTextField.typeText(words[Int(secondWordLabel)! - 1])
        secondTextField.typeText("\n")
        
        app.buttons["Submit"].tap()
        
        // Fill in a pass phrase
        // ..
    }
    
}