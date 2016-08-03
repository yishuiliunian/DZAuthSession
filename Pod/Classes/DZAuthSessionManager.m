//
//  DZAuthSessionManager.m
//  Pods
//
//  Created by stonedong on 16/4/4.
//
//

#import "DZAuthSessionManager.h"
#import "DZAuth.h"
#import "Valet.h"


NSString* const kDZAuthSessionRegisterActive = @"kDZAuthSessionRegisterActive";
NSString* const kDZAuthSessionResignActive = @"kDZAuthSessionResignActive";

@interface DZAuthSessionManager ()
{
    dispatch_queue_t _modifyQueue;
    VALValet* _valet;
    NSMutableDictionary* _allSessionsMap;
}
@end

static NSString* kDZAuthAllSessions = @"kDZAuthAllSessions-v2";
static NSString* kDZAuthActiveUserID = @"kDZAuthActiveUserID------";

@implementation DZAuthSessionManager

+ (DZAuthSessionManager*) shareManager
{
    static DZAuthSessionManager* sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [DZAuthSessionManager new];
    });
    return sessionManager;
}

- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    _modifyQueue = dispatch_queue_create("com.dzpqzb.auth.queuq", nil);
    _valet = [[VALValet alloc] initWithIdentifier:@"com.dzpqzb.auth.x" accessibility:VALAccessibilityAlways];
    [self loadDataFromLocal];
    return self;
}
- (void) loadDataFromLocal
{
    NSData*  data=  [_valet objectForKey:kDZAuthAllSessions];
    if (!data || ![data isKindOfClass:[NSData class]]) {
        [_valet removeObjectForKey:kDZAuthAllSessions];
        return;
    }
    NSDictionary* authMap= [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _allSessionsMap = [NSMutableDictionary dictionaryWithDictionary:authMap];
    NSString* activeUserID = [_valet stringForKey:kDZAuthActiveUserID];
    DZAuth* auth = [_allSessionsMap objectForKey:activeUserID];
    if (auth) {
        _activeSession = auth;
    }
    if (!_activeSession) {
        NSLog(@"NULL active auth");
    }
}
- (void) store
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_allSessionsMap];
    if (!data) {
        return;
    }
    [_valet setObject:data forKey:kDZAuthAllSessions];
}
- (BOOL) registerSession:(DZAuth *)session
{
    NSParameterAssert(session);
    NSParameterAssert(session.userID);
    dispatch_barrier_sync(_modifyQueue, ^{
        _allSessionsMap[session.userID] = session;
        [self store];
    });

    return YES;
}

- (void) registerActiveSession:(DZAuth*)session
{
    [self registerSession:session];
    [self registerActiveByID:session.userID];
}

- (BOOL) removeSessionByID:(NSString *)userID
{
    dispatch_barrier_sync(_modifyQueue, ^{
        if ([_allSessionsMap  objectForKey:userID]) {
            [_allSessionsMap removeObjectForKey:userID];
            [self store];
        }
    });
}

- (void) registerActiveByID:(NSString*)userID
{
    NSParameterAssert(userID);
   dispatch_barrier_sync(_modifyQueue, ^{
       DZAuth* auth = [_allSessionsMap objectForKey:userID];
       if (auth) {
           _activeSession = auth;
           [_valet setString:userID forKey:kDZAuthActiveUserID];
       }
   });
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionRegisterActive object:nil];
}

+ (void) registerAuthClass:(Class)cla
{
    
}

- (BOOL) resignActiveSession
{
    [_valet removeObjectForKey:kDZAuthActiveUserID];
    _activeSession = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionResignActive object:nil];
}

- (void) removeAllSessions
{
    dispatch_barrier_sync(_modifyQueue, ^{
        [_allSessionsMap removeAllObjects];
        [_valet removeObjectForKey:kDZAuthActiveUserID];
        [self store];
    });
}
@end

