/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2008 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/


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
#endif /* __cplusplus */

/*
 * The sockit_owm_state structure is used to hold device specific data.
 * This includes the transmit and receive buffers.
 *
 * An instance of this structure is created in the auto-generated
 * alt_sys_init.c file for each UART listed in the systems SOPC file. This is
 * done using the SOCKIT_OWM_STATE_INSTANCE macro given below.
 */

typedef struct sockit_owm_state_s
{
  // constants
  void*            base;            // The base address of the device
  alt_u32          own;             // Number of onewire ports
  // status
  alt_u32          ena;             // interrupt enable status
  alt_u32          use;             // Aquire status
  alt_u32          ovd;             // Overdrive status
  alt_u32          pwr;             // Power status
  // OS multitasking features
//ALT_FLAG_GRP    (srx)             // receive event flag
#ifdef UCOS_II
  ALT_FLAG_GRP    (irq)             // transmit event flag
  ALT_SEM         (trn)             // transfer lock semaphore
#else
  alt_u32          irq;             // transmit event flag
  alt_u32          trn;             // transfer lock semaphore
#endif
} sockit_owm_state;

/*
 * The macro ALTERA_AVALON_UART_INSTANCE is used by the auto-generated file
 * alt_sys_init.c to create an instance of this device driver state.
 * ALTERA_AVALON_UART_INSTANCE is mapped below to SOCKIT_OWM_STATE_INSTANCE.
 */

#define SOCKIT_OWM_INSTANCE(name, state) \
  sockit_owm_state sockit_owm = { (void*) name##_BASE, name##_OWN, 0, 0}; \
  void* state = name##_BASE
/*
 * sockit_owm_init() is called by the auto-generated function
 * alt_sys_init() for each UART in the system. This is done using the
 * SOCKIT_OWM_INIT macro given below.
 *
 * This function is responsible for performing all the run time initilisation
 * for a device instance, i.e. registering the interrupt handler, and
 * regestering the device with the system.
 */

extern void sockit_owm_init(alt_u32 irq);

/*
 * The macro SOCKIT_OWM_STATE_INIT is used by the auto-generated file
 * alt_sys_init.c to initialize an instance of the device driver state.
 *
 * This macro performs a sanity check to ensure that the interrupt has been
 * connected for this device. If not, then an apropriate error message is
 * generated at build time.
 */

#define SOCKIT_OWM_INIT(name, state)                                       \
  if (name##_IRQ == ALT_IRQ_NOT_CONNECTED)                                 \
  {                                                                        \
    ALT_LINK_ERROR ("Error: Interrupt not connected for " #name ". "       \
                    "You have selected the interrupt driven version of "   \
                    "the SocKit Avalon 1-wire master (mini) driver, but "  \
                    "the interrupt is not connected for this device. You " \
                    "can select a polled mode driver by checking the "     \
                    "'small driver' option in the HAL configuration "      \
                    " window, or by using the -DSOCKIT_OWM_SMALL "         \
                    "preprocessor flag.");                                 \
  }                                                                        \
  else                                                                     \
  {                                                                        \
    sockit_owm_init(name##_IRQ);                                           \
  }

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SOCKIT_OWM_H__ */
