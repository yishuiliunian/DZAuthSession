//
//  DZAuth.m
//  Pods
//
//  Created by stonedong on 16/4/4.
//
//

#import "DZAuth.h"

static NSString* kDZAuthPassword = @"p";
static NSString* kDZAuthUserID = @"u";
static NSString* kDZAuthToken = @"t";

@implementation DZAuth
- (BOOL) isEqual:(DZAuth*)object
{
    if ([object.userID isEqual:self.userID]) {
        return YES;
    }
    return NO;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userID forKey:kDZAuthUserID];
    [aCoder encodeObject:self.password forKey:kDZAuthPassword];
    [aCoder encodeObject:self.token forKey:kDZAuthToken];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return self;
    }
    self.password = [aDecoder decodeObjectForKey:kDZAuthPassword];
    self.userID = [aDecoder decodeObjectForKey:kDZAuthUserID];
    self.token = [aDecoder decodeObjectForKey:kDZAuthToken];
    return self;
}
@end
