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


NSString* const kDZAuthSessionRegisterActive   = @"kDZAuthSessionRegisterActive";
NSString* const kDZAuthSessionResignActive     = @"kDZAuthSessionResignActive";
NSString* const kDZAuthSessionWillResignActive = @"kDZAuthSessionWillResignActive";

@interface DZAuthSessionManager ()
{
    VALValet* _valet;
    NSMutableDictionary* _allSessionsMap;
}
@end

static NSString* kDZAuthAllSessions = @"kDZAuthAllSessions-v2";
static NSString* kDZAuthActiveUserID = @"kDZAuthActiveUserID------";

@implementation DZAuthSessionManager
@synthesize activeSession=_activeSession;
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
    if (auth != nil) {
        _activeSession = auth;
    }
    if (self.activeSession == nil) {
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
    @synchronized (self) {
        _allSessionsMap[session.userID] = session;
        [self store];
    }
    return YES;
}

- (void) registerActiveSession:(DZAuth*)session
{
    NSParameterAssert(session);
    NSParameterAssert(session.userID);
    @synchronized (self) {
        _allSessionsMap[session.userID] = session;
        [self store];
        _activeSession = session;
        [_valet setString:session.userID forKey:kDZAuthActiveUserID];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionRegisterActive object:nil];
}

- (BOOL) removeSessionByID:(NSString *)userID
{
    @synchronized (self) {
        if ([_allSessionsMap  objectForKey:userID]) {
            [_allSessionsMap removeObjectForKey:userID];
            [self store];
        }
    }
}

- (void) registerActiveByID:(NSString*)userID
{
    NSParameterAssert(userID);
    @synchronized (self) {
        DZAuth* auth = [_allSessionsMap objectForKey:userID];
        if (auth) {
            _activeSession = auth;
            [_valet setString:userID forKey:kDZAuthActiveUserID];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionRegisterActive object:nil];
}

- (DZAuth*) activeSession
{
    @synchronized (self) {
        return _activeSession;
    }
}
+ (void) registerAuthClass:(Class)cla
{
    
}
- (NSArray*) allSessions
{
    @synchronized (self) {
        return [_allSessionsMap allValues];
    }
}
- (BOOL) resignActiveSession
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionWillResignActive object:nil];
    @synchronized (self) {
        [_valet removeObjectForKey:kDZAuthActiveUserID];
        _activeSession = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionResignActive object:nil];
}

- (void) removeAllSessions
{
    @synchronized (self) {
        [_allSessionsMap removeAllObjects];
        [_valet removeObjectForKey:kDZAuthActiveUserID];
        [self store];
    }
}
@end

