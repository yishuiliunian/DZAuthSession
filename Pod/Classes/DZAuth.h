//
//  DZAuth.h
//  Pods
//
//  Created by stonedong on 16/4/4.
//
//

#import <Foundation/Foundation.h>
/**
 *  Class for store authentical info
 */
@interface DZAuth : NSObject <NSCoding>
/**
 *  user identify, it may be guid
 */
@property (nonatomic, strong) NSString* userID;
/**
 *  when use restfult apis, server will give an token to auth
 */
@property (nonatomic, strong) NSString* token;
/**
 *  the origin password, save it carefully
 */
@property (nonatomic, strong) NSString* password;

/**
 *  user account name, uarally it may be phone number or email
 */
@property (nonatomic, strong) NSString* accountName;
@end
