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


#include <fcntl.h>

#include "sys/alt_dev.h"
#include "sys/alt_irq.h"
#include "sys/ioctl.h"
#include "sys/alt_errno.h"

#include "sockit_owm_regs.h"
#include "sockit_owm.h"

extern sockit_owm_state sockit_owm;

#ifndef SOCKIT_OWM_POLLING

//////////////////////////////////////////////////////////////////////////////
// interrupt implementation
//////////////////////////////////////////////////////////////////////////////

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void sockit_owm_irq ();
#else
static void sockit_owm_irq (alt_u32 id);
#endif

void sockit_owm_init (alt_u32 irq)
{
  int error;
  // initialize semaphore for 1-wire cycle locking
  error = ALT_FLAG_CREATE (sockit_owm.irq, 0) ||
          ALT_SEM_CREATE  (sockit_owm.cyc, 1);

  if (!error) {
    // enable interrupt
    sockit_owm.ien = 0x1;
    // register the interrupt handler
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    alt_ic_isr_register (0, irq, sockit_owm_irq, NULL, 0x0);
#else
    alt_irq_register (irq, NULL, sockit_owm_irq);
#endif
  }
}

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void sockit_owm_irq(void * state)
#else
static void sockit_owm_irq(void * state, alt_u32 id)
#endif
{
  // clear onewire interrupts
  IORD_SOCKIT_OWM (sockit_owm.base);
  // set the flag indicating a completed 1-wire cycle
  ALT_FLAG_POST (sockit_owm.irq, 0x1, OS_FLAG_SET);
}
#else

//////////////////////////////////////////////////////////////////////////////
// polling implementation
//////////////////////////////////////////////////////////////////////////////

#endif
