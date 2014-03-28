//
//  MFileClient.h
//  MFiles
//
//  Created by David Paul Quesada on 3/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFileClient : NSObject

+(instancetype)sharedClient;

@property NSString *uniqname;

-(void)getFilesAtPath:(NSString *)path withCompletionHandler:(void (^)(NSArray *filenames))completion;

@end
