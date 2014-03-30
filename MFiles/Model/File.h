//
//  File.h
//  MFiles
//
//  Created by David Quesada on 3/30/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FileTypeDirectory;

@interface File : NSObject

@property(readonly) NSString *title;
@property(readonly) NSInteger date; // TODO: figure out what this number means. (UNIX timestamp?)
@property(readonly) NSUInteger size;
@property(readonly) NSString *type;

// Doesn't include the AFS prefix.
@property(readonly) NSString *directory;

@property(readonly) NSString *pathInAFS;

@property(readonly) BOOL isDirectory;


-(id)initWithJSObject:(NSDictionary *)obj;

@end
