//
//  File.m
//  MFiles
//
//  Created by David Quesada on 3/30/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "File.h"

NSString * const FileTypeDirectory = @"0000000dir";

@implementation File

-(id)initWithJSObject:(NSDictionary *)obj
{
    self = [super init];
    if (self)
    {
        _title = obj[@"title"];
        _date = [obj[@"date"] integerValue];
        _size = [obj[@"size"] integerValue];
        _type = obj[@"type"];
    }
    return self;
}

-(BOOL)isDirectory
{
    return [_type isEqualToString:FileTypeDirectory];
}

@end
