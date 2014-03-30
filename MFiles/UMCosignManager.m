//
//  UMCosignManager.m
//  MFiles
//
//  Created by David Quesada on 3/30/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UMCosignManager.h"

@interface UMCosignManager()

-(id)initAsDefaultManager;
-(NSString *)valueForCookie:(NSString *)cookieName inDomain:(NSString *)domain;
-(void)setValue:(NSString *)value forCookie:(NSString *)cookieName inDomain:(NSString *)domain;

// Returns the cosign value stored in the user defaults. This may or may not be actually
// synchronized with the real cosign value.
@property NSString *defaultCosignValue;

-(NSArray *)cookieDictionariesToPersist;

@end


@implementation UMCosignManager

+(void)load
{
    [[UMCosignManager sharedManager] readCookiesFromUserDefaults];
}

+(instancetype)sharedManager
{
    static UMCosignManager *manager = nil;
    if (!manager)
        manager = [[self alloc] initAsDefaultManager];
    return manager;
}

-(id)init
{
    return nil;
}

-(id)initAsDefaultManager
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(NSArray *)cookieDictionariesToPersist
{
    NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableArray *cookies = [NSMutableArray new];
    
    for (NSHTTPCookie *cookie in store.cookies)
    {
        if ([cookie.domain rangeOfString:@"umich.edu"].location != NSNotFound)
            if ([cookie.name rangeOfString:@"cosign"].location != NSNotFound)
                [cookies addObject:cookie.properties];
    }
    
    return cookies;
}

-(BOOL)writeCookiesToUserDefaults
{
    NSArray *array = [self cookieDictionariesToPersist];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [def setObject:array forKey:@"UMCosignCookies"];
    [def synchronize];
    return YES;
}

-(BOOL)readCookiesFromUserDefaults
{
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:@"UMCosignCookies"];
    if (![array isKindOfClass:[NSArray class]])
        return NO;
    
    NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSDictionary *props in array)
    {
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:props];
        [store setCookie:cookie];
    }
    return YES;
}

-(NSString *)valueForCookie:(NSString *)cookieName inDomain:(NSString *)domain
{
    NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSURL *url = [NSURL URLWithString:domain];
    NSArray *cookies = [store cookiesForURL:url];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        if ([cookie.name isEqualToString:cookieName])
            return cookie.value;
    }
    
    return nil;
}

-(void)setValue:(NSString *)value forCookie:(NSString *)cookieName inDomain:(NSString *)domain
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    if ([domain hasPrefix:@"http://"])
        domain = [domain substringFromIndex:7];
    else if ([domain hasPrefix:@"https://"])
        domain = [domain substringFromIndex:8];
    
    cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                        NSHTTPCookieDomain : domain,
                                                        NSHTTPCookieName : cookieName,
                                                        NSHTTPCookieValue : value,
                                                        NSHTTPCookieSecure : @(YES),
                                                        NSHTTPCookiePath : @"/"
                                                        }];
    [cookieStore setCookie:cookie];
}

-(NSString *)MFileCosign
{
    return [self valueForCookie:@"cosign-mfile.umich.edu" inDomain:@"mfile.umich.edu"];
}

-(void)setMFileCosign:(NSString *)MFileCosign
{
    [self setValue:MFileCosign forCookie:@"cosign-mfile.umich.edu" inDomain:@"mfile.umich.edu"];
}

-(NSString *)MPrintCosign
{
    return [self valueForCookie:@"cosign-mprint" inDomain:@"mprint.umich.edu"];
}

-(void)setMPrintCosign:(NSString *)MPrintCosign
{
    return [self setValue:MPrintCosign forCookie:@"cosign-mprint" inDomain:@"mprint.umich.edu"];
}

@end
