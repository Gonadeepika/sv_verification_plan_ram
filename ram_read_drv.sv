/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_read_drv.sv   

Description    :  Driver class for dual port ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

*********************************************************************************************/

class ram_read_drv;

   //Virtual interface
   virtual ram_if.RD_DRV_MP rd_drv_if;

   //Transaction Handle 
   ram_trans data2duv;

   //Mailbox Handle
   //Generator to Read Driver    
   mailbox #(ram_trans) gen2rd;  

   //constructor - Will connect the static interface with virtual interface
   //connects the mailbox
   function new(virtual ram_if.RD_DRV_MP rd_drv_if,
                    mailbox #(ram_trans) gen2rd);
      this.rd_drv_if = rd_drv_if;
      this.gen2rd    = gen2rd;
   endfunction: new

   //drive - drives the transaction to DUT
   virtual task drive();
      @(rd_drv_if.rd_drv_cb);
      rd_drv_if.rd_drv_cb.rd_address <= data2duv.rd_address;
      rd_drv_if.rd_drv_cb.read       <= data2duv.read;     
      repeat(2) 
         @(rd_drv_if.rd_drv_cb);
      rd_drv_if.rd_drv_cb.read <= '0;
   endtask: drive
   
   //start  - collects the transaction from generator
   virtual task start();
      fork
         forever
            begin
               gen2rd.get(data2duv);
               drive();
            end
      join_none
   endtask: start

endclass: ram_read_drv
