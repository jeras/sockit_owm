//////////////////////////////////////////////////////////////////////////////                                                                                          
//                                                                          //
//  Minimalistic 1-wire (onewire) master with Avalon MM bus interface       //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This RTL is free hardware: you can redistribute it and/or modify        //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This RTL is distributed in the hope that it will be useful,             //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


#ifndef __SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REGS_H__
#define __SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REGS_H__

#include <io.h>

#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REG                 0
#define IOADDR_SOCKIT_AVALON_ONEWIRE_MASTER_MINI(base)        \
        __IO_CALC_ADDRESS_NATIVE(base, SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REG)
#define IORD_SOCKIT_AVALON_ONEWIRE_MASTER_MINI(base)          \
        IORD(base, SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REG) 
#define IOWR_SOCKIT_AVALON_ONEWIRE_MASTER_MINI(base, data)    \
        IOWR(base, SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REG, data)

#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_OVD_MSK             (0x01)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_OVD_OFST            (0)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_RST_MSK             (0x02)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_RST_OFST            (1)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_DTX_MSK             (0x04)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_DTX_OFST            (2)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_DRX_MSK             (0x08)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_DRX_OFST            (3)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_STX_MSK             (0x10)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_STX_OFST            (4)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_SRX_MSK             (0x20)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_SRX_OFST            (5)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_ETX_MSK             (0x40)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_ETX_OFST            (6)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_ERX_MSK             (0x80)
#define SOCKIT_AVALON_ONEWIRE_MASTER_MINI_ERX_OFST            (7)

#endif /* __SOCKIT_AVALON_ONEWIRE_MASTER_MINI_REGS_H__ */
