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
@interface DZAuthSessionManager ()
{
    dispatch_queue_t _modifyQueue;
    VALValet* _valet;
    NSArray* _allSessions;
}
@end

static NSString* kDZAuthAllSessions = @"kDZAuthAllSessions";
static NSString* kDZAuthActiveUserID = @"kDZAuthActiveUserID";

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
    dispatch_barrier_sync(_modifyQueue, ^{
        _allSessions = array;
    });
    NSString* activeUserID = [_valet stringForKey:kDZAuthActiveUserID];
    NSString* activeUserStand = [[NSUserDefaults standardUserDefaults] objectForKey:kDZAuthActiveUserID];
    for (DZAuth* auth in _allSessions) {
        if ([auth.userID isEqualToString:activeUserID] && [activeUserID isEqualToString:activeUserStand]) {
            _activeSession = auth;
        }
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
    __block BOOL result;
    dispatch_barrier_sync(_modifyQueue, ^{
        for(;;){
            for (DZAuth* s   in self.allSessions) {
                if ([s isEqual:session]) {
                    s.password = session.password;
                    s.token = session.token;
                    [self store];
                    result = YES;
                    break;
                }
            }
            NSMutableArray* array = [ NSMutableArray arrayWithArray:self.allSessions];
            [array addObject:session];
            _allSessions = array;
            [self store];
            result = YES;
            break;
        }
    });
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
               [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kDZAuthActiveUserID];
               [[NSUserDefaults standardUserDefaults] synchronize];
               break;
           }
       }
   });
    
}

- (BOOL) resignActiveSession
{
    [_valet removeObjectForKey:kDZAuthActiveUserID];
    _activeSession = nil;
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

