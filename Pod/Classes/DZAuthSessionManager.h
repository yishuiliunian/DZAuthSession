//
//  DZAuthSessionManager.h
//  Pods
//
//  Created by stonedong on 16/4/4.
//
//

#import <Foundation/Foundation.h>



extern NSString* const kDZAuthSessionRegisterActive;
extern NSString* const kDZAuthSessionResignActive;
extern NSString* const kDZAuthSessionWillResignActive;

/**
 *  Share Authentical Session Manager
 *
 */
#define DZShareAuthSessionManager [DZAuthSessionManager shareManager]

/**
 * The Active Auth Session, if it exist. otherwise it will return Nil.
 *
 */
#define DZActiveAuthSession [DZShareAuthSessionManager activeSession]

@class DZAuth;
@interface DZAuthSessionManager : NSObject
/**
 *  All auth sessions that are registed at this app
 */
@property (nonatomic, strong,readonly) NSArray* allSessions;
/**
 *  The Active Auth Session that contains all the authentical info , like userid token and password.
 */
@property (atomic, strong, readonly) DZAuth* activeSession;
/**
 *  Share Manager
 *
 *  @return Share Manager
 */
+ (DZAuthSessionManager*) shareManager;

/**
 *  Register the auth data class
 *
 *  @param cla Auth Model data class
 */
+ (void) registerAuthClass:(Class)cla;
/**
 *  register an authentical session
 *
 *  @param session the auth session
 *
 *  @return if success it will return YES, if an error occurs it will return NO
 */
- (BOOL) registerSession:(DZAuth*)session;
/**
 *  remove an auth session by userid
 *
 *  @param userID the user identify
 *
 *  @return if success it will return YES, if an error occurs it will return NO
 */
- (BOOL) removeSessionByID:(NSString*)userID;

/**
 *  remove all auth session , and resign the active auth, be carefully
 */
- (void) removeAllSessions;

/**
 *  resign the active auth ,but it will not erase the auth session data
 *
 *  @return if success it will return YES, if an error occurs it will return NO
 */
- (BOOL) resignActiveSession;

/**
 *  register active auth session by userid
 *
 *  @param userID the user identify
 */
- (void) registerActiveByID:(NSString*)userID;


/**
 *  register an auth session , and make it active
 *
 *  @param session the auth session will active and store
 */
- (void) registerActiveSession:(DZAuth*)session;
@end
