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
    NSArray* _allSessions;
}
@end

static NSString* kDZAuthAllSessions = @"kDZAuthAllSessions";
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
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _allSessions = array;
    NSString* activeUserID = [_valet stringForKey:kDZAuthActiveUserID];
    for (DZAuth* auth in _allSessions) {
        if ([auth.userID isEqualToString:activeUserID]) {
            _activeSession = auth;
        }
    }
    if (!_activeSession) {
        NSLog(@"NULL active auth");
    }
}
- (void) store
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_allSessions];
    if (!data) {
        return;
    }
    [_valet setObject:data forKey:kDZAuthAllSessions];
}
- (BOOL) registerSession:(DZAuth *)session
{
    NSParameterAssert(session);
    dispatch_barrier_sync(_modifyQueue, ^{
        for(;;){
            DZAuth* exsitAuth = nil;
            for (DZAuth* s   in self.allSessions) {
                if ([s isEqual:session]) {
                    s.password = session.password;
                    s.token = session.token;
                    s.userID = session.userID;
                    s.accountName = session.accountName;
                    exsitAuth = s;
                    break;
                }
            }
            
            NSMutableArray* array = [ NSMutableArray arrayWithArray:self.allSessions];
            if (!exsitAuth) {
                [array addObject:session];
            }
            _allSessions = array;
            [self store];
            break;
        }
    });
        [[NSNotificationCenter defaultCenter] postNotificationName:kDZAuthSessionRegisterActive object:nil];
    return YES;
}

- (BOOL) removeSessionByID:(NSString *)userID
{
    dispatch_barrier_sync(_modifyQueue, ^{
        NSMutableArray* sessions = [NSMutableArray arrayWithArray:_allSessions];
        for (DZAuth* auth in _allSessions) {
            if ([auth.userID isEqualToString:userID]) {
                [sessions removeObject:auth];
            }
        }
        _allSessions = sessions;
        [self store];
    });
}

- (void) registerActiveByID:(NSString*)userID
{
   dispatch_sync(_modifyQueue, ^{
       for (DZAuth* auth in _allSessions) {
           if ([auth.userID isEqualToString:userID]) {
               [_valet setString:userID forKey:kDZAuthActiveUserID];
               _activeSession = auth;
               [[NSUserDefaults standardUserDefaults] synchronize];
               break;
           }
       }
   });
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
        _allSessions = [NSArray new];
        _activeSession = nil;
        [_valet removeObjectForKey:kDZAuthActiveUserID];
        [self store];
    });
}
@end

