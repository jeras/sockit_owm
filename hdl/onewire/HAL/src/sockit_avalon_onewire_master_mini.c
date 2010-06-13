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


#include <fcntl.h>

#include "sys/alt_dev.h"
#include "sys/alt_irq.h"
#include "sys/ioctl.h"
#include "sys/alt_errno.h"

#include "altera_avalon_uart.h"
#include "sockit_avalon_onewire_master_mini_regs.h"
#include "sockit_avalon_onewire_master_mini.h"

//#if !defined(ALT_USE_SMALL_DRIVERS) && !defined(SOCKIT_AVALON_ONEWIRE_MASTER_MINI_SMALL)
#if 0

/* ----------------------------------------------------------- */
/* ------------------------- FAST DRIVER --------------------- */
/* ----------------------------------------------------------- */

/*
 * sockit_avalon_onewire_master_mini_init() is called by the auto-generated function
 * alt_sys_init() in order to initialize a particular instance of this device.
 * It is responsible for configuring the device and associated software
 * constructs.
 */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void sockit_avalon_onewire_master_mini_irq(void* context);
#else
static void sockit_avalon_onewire_master_mini_irq(void* context, alt_u32 id);
#endif

static void sockit_avalon_onewire_master_mini_irq_srx(sockit_avalon_onewire_master_mini_state* sp, alt_u32 status);
static void sockit_avalon_onewire_master_mini_irq_stx(sockit_avalon_onewire_master_mini_state* sp, alt_u32 status);

void
sockit_avalon_onewire_master_mini_init(sockit_avalon_onewire_master_mini_state* sp, alt_u32 irq)
{
  void* base = sp->base;
  /* enable interrupts at the device */
  sp->reg = SOCKIT_AVALON_ONEWIRE_MASTER_MINI_STX_MSK
          | SOCKIT_AVALON_ONEWIRE_MASTER_MINI_SRX_MSK;
  /* register the interrupt handler */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
  alt_ic_isr_register (0, irq, sockit_avalon_onewire_master_mini_irq, sp, 0x0);
#else
  alt_irq_register (irq, sp, sockit_avalon_onewire_master_mini_irq);
#endif
}

/*
 * sockit_avalon_onewire_master_mini_irq() is the interrupt handler
 * registered at configuration time for processing 1-wire interrupts.
 */

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void sockit_avalon_onewire_master_mini_irq(void* context)
#else
static void sockit_avalon_onewire_master_mini_irq(void* context, alt_u32 id)
#endif
{
  alt_u32 reg;

  sockit_avalon_onewire_master_mini_state* sp = (sockit_avalon_onewire_master_mini_state*) context;
  void* base = sp->base;

  // determine the cause of the interrupt
  reg = IORD_SOCKIT_AVALON_ONEWIRE_MASTER_MINI(base);

  /* process a RX irq */
  if (reg & SOCKIT_AVALON_ONEWIRE_MASTER_MINI_SRX_MSK)
    sockit_avalon_onewire_master_mini_irq_srx(sp, reg);

  /* process a TX irq */
  if (reg & SOCKIT_AVALON_ONEWIRE_MASTER_MINI_STX_MSK)
    sockit_avalon_onewire_master_mini_irq_stx(sp, reg);
}

/*
 * sockit_avalon_onewire_master_mini_txirq() is called by sockit_avalon_onewire_master_mini_irq() to process a
 * transmit interrupt. It transfers data from the transmit buffer to the
 * device, and sets the apropriate flags to indicate that there is
 * data ready to be processed.
 */

static void sockit_avalon_onewire_master_mini_srx(sockit_avalon_onewire_master_mini_state* sp, alt_u32 status)
{
}

static void sockit_avalon_onewire_master_mini_stx(sockit_avalon_onewire_master_mini_state* sp, alt_u32 status)
{
}

#endif /* fast driver */
