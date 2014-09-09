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

// e.g. /Classes/ENGR101/Notes1.pdf
@property(readonly) NSString *path;

// Returns the fully qualified AFS directory of this file. e.g. /afs/umich.edu/user/u/n/uniqname/Stuff/MATH123
@property(readonly) NSString *pathInAFS;

@property(readonly) BOOL isDirectory;


-(id)initWithJSObject:(NSDictionary *)obj inDirectory:(NSString *)dir afsPrefix:(NSString *)prefix;

@end
