//
//  LoginViewController.h
//  MFiles
//
//  Created by David Paul Quesada on 3/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>
@optional
-(void)loginViewController:(LoginViewController *)controller didDismissWithLoginResult:(BOOL)loggedIn;
@end

@interface LoginViewController : UINavigationController

@property(weak) id<LoginViewControllerDelegate> delegate;

-(id)init;

@end
