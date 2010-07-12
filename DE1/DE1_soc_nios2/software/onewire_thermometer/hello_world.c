/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "sockit_owm_regs.h"
#include "system.h"

#include "ownet.h"
#include "temp10.h"
#include "findtype.h"
//#include "ser550.h"

// defines
#define MAXDEVICES         20
#define ONEWIRE_P           0

// local functions
void DisplaySerialNum(uchar sn[8]);
int WeakReadTemperature(int, uchar*, float*);

int main()
{
  printf("Hello from Nios II!\n");

  uchar FamilySN[MAXDEVICES][8];
  float current_temp;
  int i = 0;
  int j = 0;
  int NumDevices = 0;
  SMALLINT didRead = 0;

  //use port number for 1-wire
  uchar portnum = ONEWIRE_P;

  //----------------------------------------
  // Introduction header
  printf("\r\nTemperature\r\n");

  // attempt to acquire the 1-Wire Net
  if (!owAcquire(portnum,NULL))
  {
     printf("Acquire failed\r\n");
     while(owHasErrors())
        printf("  - Error %d\r\n", owGetErrorNum());
     return 1;
  }

  do
  {
     j = 0;
     // Find the device(s)
     NumDevices = FindDevices(portnum, FamilySN, 0x28, MAXDEVICES);
     if (NumDevices>0)
     {
        printf("\r\n");
        // read the temperature and print serial number and temperature
        for (i = NumDevices; i; i--)
        {
           printf("(%d) ", j++);
           DisplaySerialNum(FamilySN[i-1]);
           //if(owHasPowerDelivery(portnum))
           if(0)
           {
              didRead = ReadTemperature(portnum, FamilySN[i-1],&current_temp);
           }
           else
           {
              didRead = WeakReadTemperature(portnum, FamilySN[i-1],&current_temp);
           }

           if (didRead)
           {
              printf(" %5.1f Celsius\r\n", current_temp);
           }
           else
           {
              printf("  Convert failed.  Device is");
              if(!owVerify(portnum, FALSE))
                 printf(" not");
              printf(" present.\r\n");
              while(owHasErrors())
                 printf("  - Error %d\r\n", owGetErrorNum());
           }

        }
     }
     else
        printf("No temperature devices found!\r\n");

     printf("\r\nPress any key to continue\r\n");
     i = getchar();
  }
  while (i!='q');

  // release the 1-Wire Net
  owRelease(portnum);

  return 0;
}
// -------------------------------------------------------------------------------
// Read and print the serial number.
//
void DisplaySerialNum(uchar sn[8])
{
   int i;
   for (i = 7; i>=0; i--)
      printf("%02X", (int)sn[i]);
}

//----------------------------------------------------------------------
// Read the temperature of a DS1920/DS1820 without using Power Delivery
//
// 'portnum'     - number 0 to MAX_PORTNUM-1.  This number was provided to
//                 OpenCOM to indicate the port number.
// 'SerialNum'   - Serial Number of DS1920/DS1820 to read temperature from
// 'Temp '       - pointer to variable where that temperature will be
//                 returned
//
// Returns: TRUE(1)  temperature has been read and verified
//          FALSE(0) could not read the temperature, perhaps device is not
//                   in contact
//
int WeakReadTemperature(int portnum, uchar *SerialNum, float *Temp)
{
   uchar rt=FALSE;
   uchar send_block[30],lastcrc8;
   int send_cnt=0, tsht, i, loop=0;

   setcrc8(portnum,0);

   // set the device serial number to the counter device
   owSerialNum(portnum,SerialNum,FALSE);

   for (loop = 0; loop < 2; loop ++)
   {
      // access the device
      if (owAccess(portnum))
      {
         // send the convert temperature command
         owTouchByte(portnum,0x44);

         // sleep for 1 second
         msDelay(1000);

         // turn off the 1-Wire Net strong pull-up
         if (owLevel(portnum,MODE_NORMAL) != MODE_NORMAL)
            return FALSE;

         // access the device
         if (owAccess(portnum))
         {
            // create a block to send that reads the temperature
            // read scratchpad command
            send_block[send_cnt++] = 0xBE;
            // now add the read bytes for data bytes and crc8
            for (i = 0; i < 9; i++)
               send_block[send_cnt++] = 0xFF;

            // now send the block
            if (owBlock(portnum,FALSE,send_block,send_cnt))
            {
//               printf ("\n1-wire device scratchpad (");
//               for (i=0; i<10; i++)  printf("-%02X", (int)send_block[i]);
//               printf ("-)\n");
               // perform the CRC8 on the last 8 bytes of packet
               for (i = send_cnt - 9; i < send_cnt; i++)
                  lastcrc8 = docrc8(portnum,send_block[i]);

               // verify CRC8 is correct
               if (lastcrc8 == 0x00)
               {
                  // calculate the high-res temperature
            	  tsht =        send_block[2] << 8;
            	  tsht = tsht | send_block[1];
            	  if (tsht & 0x00001000)
            		  tsht = tsht | 0xffff0000;
            	  printf (" tsht = 0x%08X ", tsht);
                  *Temp = ((float) tsht)/16;
                  // success
                  rt = TRUE;
               }
            }
         }
      }

   }

   // return the result flag rt
   return rt;
}

