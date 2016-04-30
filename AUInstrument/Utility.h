//
//  Utility.h
//  AUInstrument
//
//  Created by Eric on 4/16/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#ifndef Utility_h
#define Utility_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

// QLog doesn't display extra NSLog information
#define QLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


#endif /* Utility_h */
