//
//  HelloXAppController.h
//  HelloX
//
//  Created by Ngo Duc Hiep on 5/26/12.
//  Copyright PTT Solution Inc 2012. All rights reserved.
//

@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate,UIApplicationDelegate> {
    UIWindow *window;
    RootViewController	*viewController;
}

@end

