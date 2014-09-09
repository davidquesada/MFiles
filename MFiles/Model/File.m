//
//  File.m
//  MFiles
//
//  Created by David Quesada on 3/30/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "File.h"

// MFile returns this as the 'type' property of a directory.
NSString * const FileTypeDirectory = @"0000000dir";

@implementation File

-(id)initWithJSObject:(NSDictionary *)obj inDirectory:(NSString *)dir afsPrefix:(NSString *)prefix;
{
    self = [super init];
    if (self)
    {
        _title = obj[@"title"];
        _date = [obj[@"date"] integerValue];
        _size = [obj[@"size"] integerValue];
        _type = obj[@"type"];
        
        _directory = dir;
        _pathInAFS = prefix;
        for (NSString *comp in dir.pathComponents)
            _pathInAFS = [_pathInAFS stringByAppendingPathComponent:comp];
    }
    return self;
}

-(NSString *)path
{
    return [_directory stringByAppendingPathComponent:_title];
}

-(BOOL)isDirectory
{
    return [_type isEqualToString:FileTypeDirectory];
}

@end
