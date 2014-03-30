//
//  MFileClient.m
//  MFiles
//
//  Created by David Paul Quesada on 3/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MFileClient.h"
#import "File.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MFileClient ()

@property(readwrite) NSString *uniqname;
-(NSMutableArray *)itemsForResponseData:(NSData *)data;

@end

@implementation MFileClient

+(instancetype)sharedClient
{
    static MFileClient *client = nil;
    if (!client)
        client = [[self alloc] init];
    return client;
}

-(void)getFilesAtPath:(NSString *)path withCompletionHandler:(void (^)(NSArray *))completion
{
    NSString *afsPrefix = @"/afs/umich.edu/user/d/q/dquesada/";
    NSString *urlFormat = @"https://mfile.umich.edu/index.php?path=%@";
    
    for (NSString *comp in [path pathComponents])
        afsPrefix = [afsPrefix stringByAppendingPathComponent:comp];
    
    NSString *urlstr = [NSString stringWithFormat:urlFormat, afsPrefix];
    NSURL *url = [NSURL URLWithString:urlstr];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSMutableArray *items = [self itemsForResponseData:data];
        
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(items);
            });
    });
}

// Right now, this method assumes the response is normal data (e.g. fully authorized, no error pages,...);
// TODO: There are probably really good, 281-style ways to make this run fast. Creating an
// entire Javascript virtual machine just to extract this info is probably NOT the best way :P
-(NSMutableArray *)itemsForResponseData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Response: %@", string);
    
    NSRange headRange = [string rangeOfString:@"files = new Array();"];
    NSRange tailRange = [string rangeOfString:@"var displayfileman = 1;"];
    
    NSRange codeRange = NSUnionRange(headRange, tailRange);
    
    if (codeRange.location == NSNotFound || tailRange.location == NSNotFound)
    {
        NSLog(@"Unable to parse response");
        return nil;
    }
    
    NSString *filesCode = [string substringWithRange:codeRange];
    
    NSString *codeHeader = @"\
    function File( title, date, size, selected, type )              \n\
    {                                                               \n\
        this.title	 = title;	// The title of the item            \n\
        this.date	  = date * 1; // The modify date of the item    \n\
        // multiply by 1 to cast to an int                          \n\
        this.size	  = size;	 // The size of the item            \n\
        //this.selected  = selected; // Is the item selected?         \n\
        this.type	  = type;	 // The file type of the item       \n\
    }\n\n";
    
    //        this.className = false;\n\
    
    
    filesCode = [codeHeader stringByAppendingString:filesCode];
    
    JSContext *ctx = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    [ctx evaluateScript:filesCode];
    
    NSArray *fileRecords = [ctx[@"files"] toArray];
    
    // Don't include the '.' and '..' items, which are always the first two.
    if (fileRecords.count >= 2)
        fileRecords = [fileRecords subarrayWithRange:NSMakeRange(2, fileRecords.count - 2)];
    
    NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:fileRecords.count];
    
    for (NSDictionary *fileRec in fileRecords)
        [files addObject:[[File alloc] initWithJSObject:fileRec]];
    
    return files;
}

@end
