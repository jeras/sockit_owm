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


#ifndef __SOCKIT_OWM_REGS_H__
#define __SOCKIT_OWM_REGS_H__

#include <io.h>

#define SOCKIT_OWM_REG                 0
#define IOADDR_SOCKIT_OWM(base)        __IO_CALC_ADDRESS_NATIVE(base, SOCKIT_OWM_REG)
#define IORD_SOCKIT_OWM(base)          IORD(base, SOCKIT_OWM_REG)
#define IOWR_SOCKIT_OWM(base, data)    IOWR(base, SOCKIT_OWM_REG, data)

#define SOCKIT_OWM_DAT_MSK             (0x01)
#define SOCKIT_OWM_DAT_OFST            (0)
#define SOCKIT_OWM_RST_MSK             (0x02)
#define SOCKIT_OWM_RST_OFST            (1)
#define SOCKIT_OWM_OVD_MSK             (0x04)
#define SOCKIT_OWM_OVD_OFST            (2)
#define SOCKIT_OWM_PWR_MSK             (0x08)
#define SOCKIT_OWM_PWR_OFST            (3)
#define SOCKIT_OWM_STX_MSK             (0x10)
#define SOCKIT_OWM_STX_OFST            (4)
#define SOCKIT_OWM_SRX_MSK             (0x20)
#define SOCKIT_OWM_SRX_OFST            (5)
#define SOCKIT_OWM_ETX_MSK             (0x40)
#define SOCKIT_OWM_ETX_OFST            (6)
#define SOCKIT_OWM_ERX_MSK             (0x80)
#define SOCKIT_OWM_ERX_OFST            (7)

#define SOCKIT_OWM_SEL_MSK             (0x0f00)
#define SOCKIT_OWM_SEL_OFST            (8)

#define SOCKIT_OWM_POWER_MSK           (0xffff0000)
#define SOCKIT_OWM_POWER_OFST          (16)

// two common commands
#define SOCKIT_OWM_DLY_MSK             (                     SOCKIT_OWM_RST_MSK | SOCKIT_OWM_DAT_MSK)
#define SOCKIT_OWM_IDL_MSK             (SOCKIT_OWM_OVD_MSK | SOCKIT_OWM_RST_MSK | SOCKIT_OWM_DAT_MSK)

#endif /* __SOCKIT_OWM_REGS_H__ */
