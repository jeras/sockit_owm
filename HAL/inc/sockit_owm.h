//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Minimalistic 1-wire (onewire) master with Avalon MM bus interface       //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This program is free software: you can redistribute it and/or modify    //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This program is distributed in the hope that it will be useful,         //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


#ifndef __SOCKIT_OWM_H__
#define __SOCKIT_OWM_H__

#include <stddef.h>

#include "sys/alt_warning.h"

#include "os/alt_sem.h"
#include "os/alt_flag.h"
#include "alt_types.h"

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

//////////////////////////////////////////////////////////////////////////////
// global structure containing the current state of the sockit_owm driver
//////////////////////////////////////////////////////////////////////////////

typedef struct sockit_owm_state_s
{
  void*            base;            // The base address of the device
  // constants
  alt_u32          ovd_e;           // Overdrive mode               implementation enable
  alt_u32          cdr_e;           // Clock divider ratio register implementation enable
  alt_u32          own;             // Number of onewire ports
  char             btp_n[3];        // base time period for normal    mode
  char             btp_o[3];        // base time period for overdrive mode
  // clock divider ratio
  alt_u32          cdr_n;           // cdr for normal    mode
  alt_u32          cdr_o;           // cdr for overdrive mode
  alt_u32          f_dly;           // u16.16 1/ms (inverse of delay time)
  // status
  alt_u32          ien;             // interrupt enable status
  alt_u32          use;             // Aquire status
  alt_u32          ovd;             // Overdrive status
  alt_u32          pwr;             // Power status
  // OS multitasking features
  ALT_FLAG_GRP    (irq)             // interrupt event flag
  ALT_SEM         (cyc)             // transfer lock semaphore
} sockit_owm_state;

//////////////////////////////////////////////////////////////////////////////
// instantiation macro
// can be used oly once, since the driver is based on global variables
//////////////////////////////////////////////////////////////////////////////

#define SOCKIT_OWM_INSTANCE(name, state) \
  sockit_owm_state sockit_owm = { (void*) name##_BASE,  \
                                          name##_OVD_E, \
                                          name##_CDR_E, \
                                          name##_OWN,   \
                                          name##_BTP_N, \
                                          name##_BTP_O, \
                                          name##_CDR_N, \
                                          name##_CDR_O, \
                                          name##_F_DLY, \
                                          0, 0, 0, 0};  \
  void* state = (void*) name##_BASE

//////////////////////////////////////////////////////////////////////////////
// initialization function, registers the interrupt handler
//////////////////////////////////////////////////////////////////////////////

extern void sockit_owm_init(alt_u32 irq);

//////////////////////////////////////////////////////////////////////////////
// initialization macro
//////////////////////////////////////////////////////////////////////////////

#ifndef SOCKIT_OWM_POLLING
#define SOCKIT_OWM_INIT(name, state)                                       \
  if (name##_IRQ == ALT_IRQ_NOT_CONNECTED)                                 \
  {                                                                        \
    ALT_LINK_ERROR ("Error: Interrupt not connected for " #name ". "       \
                    "You have selected the interrupt driven version of "   \
                    "the sockit_owm (SoCkit 1-wire master) driver, but "   \
                    "the interrupt is not connected for this device. You " \
                    "can select a polled mode driver by checking the "     \
                    "'small driver' option in the HAL configuration "      \
                    "window, or by using the -DSOCKIT_OWM_POLLING "        \
                    "preprocessor flag.");                                 \
  }                                                                        \
  else                                                                     \
  {                                                                        \
    sockit_owm_init(name##_IRQ);                                           \
  }
#else
#define SOCKIT_OWM_INIT(name, state)
#endif

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // __SOCKIT_OWM_H__
