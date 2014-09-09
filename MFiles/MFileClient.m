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
-(NSMutableArray *)itemsForResponseData:(NSData *)data inDirectory:(NSString *)dir afsPrefix:(NSString *)prefix;

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
    
    NSString *fullPath = afsPrefix;
    
    for (NSString *comp in [path pathComponents])
        fullPath = [fullPath stringByAppendingPathComponent:comp];
    
    NSString *urlstr = [NSString stringWithFormat:urlFormat, fullPath];
    NSURL *url = [NSURL URLWithString:urlstr];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:url];

        NSMutableArray *items = [self itemsForResponseData:data inDirectory:path afsPrefix:afsPrefix];
        
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(items);
            });
    });
}

// Right now, this method assumes the response is normal data (e.g. fully authorized, no error pages,...);
// TODO: There are probably really good, 281-style ways to make this run fast. Creating an
// entire Javascript virtual machine just to extract this info is probably NOT the best way :P
-(NSMutableArray *)itemsForResponseData:(NSData *)data inDirectory:(NSString *)dir afsPrefix:(NSString *)prefix;
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
    
    // Make copies in case the calling code passed in mutable strings. // Might be a better idea to do this earlier.
    id dirValue = [dir copy];
    id afsPrefixValue = [prefix copy];
    
    for (NSDictionary *fileRec in fileRecords)
    {
        [files addObject:[[File alloc] initWithJSObject:fileRec inDirectory:dirValue afsPrefix:afsPrefixValue]];
    }
    
    return files;
}

// Sends a dummy request to pull out the "formKey" property from the hidden form.
-(NSString *)getFormKey
{
    
    // Depends on us knowing we're already logged in.
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://mfile.umich.edu"] usedEncoding:nil error:nil];
    
#warning "An INCREDIBLY dumb and fragile way to do this.";
    
    NSRange keyRange = NSMakeRange(str.length - 271, 32);
    
    NSString *key = [str substringWithRange:keyRange];
    
    return key;
}

-(void)deleteFileAtPath:(NSString *)path withCompletionHandler:(void (^)(BOOL, NSError *))completion
{
#warning "TODO: We REALLY need a better way to grab these values (particularly one that doesn't depend on the user's uniqname being 'dquesada')"
    NSString *afsPrefix = @"/afs/umich.edu/user/d/q/dquesada/";
    NSString *urlFormat = @"https://mfile.umich.edu/index.php?path=%@";
    

#warning "TODO: Find a way to make sure we keep this up to date somewhere.";
    NSString *formKey = @"d557fbcd3abaf401422fadd2e49ca70f";
    
    NSString *fullPath = afsPrefix;
    NSString *filename = [path lastPathComponent];

    for (NSString *comp in [path pathComponents])
    {
        fullPath = [fullPath stringByAppendingPathComponent:comp];
    }
    
    fullPath = [fullPath stringByDeletingLastPathComponent];
    
    NSString *urlString = [NSString stringWithFormat:urlFormat, fullPath];
    
    NSMutableString *bodyText = [NSMutableString stringWithString:@"command=delete&selectedItems="];
    
#warning "TODO: We probably need to check / escape the filename for particular characters."
    [bodyText appendString:filename];
    [bodyText appendString:@"\r\n"];
    
    
    //[bodyText stringByAppendingFormat:@"&formKey=%@", formKey];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    req.HTTPMethod = @"POST";
   
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = nil;
        
        
        [bodyText appendFormat:@"&formKey=%@", [self getFormKey]];
        req.HTTPBody = [bodyText dataUsingEncoding:NSUTF8StringEncoding];
        
        data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (data)
        {
            NSString *str = [[NSString alloc] initWithData:data encoding:4];
            NSLog(@"WOO %d", str.length);
        } // 1446165c385a49a90c603644e8fb22a9
        
        if (completion)
            completion((data != nil), error);
        
    });
}

@end
