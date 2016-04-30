//
//  Utility.hpp
//  AUInstrument
//
//  Created by Eric on 4/30/16.
//  Copyright © 2016 Eric George. All rights reserved.
//

#ifndef Utility_h
#define Utility_h

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

#endif /* Utility_h */
