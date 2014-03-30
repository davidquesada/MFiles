//
//  UMCosignManager.h
//  MFiles
//
//  Created by David Quesada on 3/30/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMCosignManager : NSObject

+(instancetype)sharedManager;

// These methods are used to persist cookies where the domain contains "umich.edu" and the name contains "cosign".
-(BOOL)writeCookiesToUserDefaults;
-(BOOL)readCookiesFromUserDefaults;

@end

@interface UMCosignManager (MPrint)
@property NSString *MPrintCosign;
@end

@interface UMCosignManager (MFile)
@property NSString *MFileCosign;
@end
