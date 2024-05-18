/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_write_drv.sv   

Description    :  Driver class for dual port ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

*********************************************************************************************/

class ram_write_drv;

   //Virtual interface 
   virtual ram_if.WR_DRV_MP wr_drv_if;

   //Transaction Handle 
   ram_trans data2duv;

   //Mailbox Handle     
   //Generator to Write Driver
   mailbox #(ram_trans) gen2wr;  

   //constructor - will connect the static interface with virtual interface
   //connects the mailbox    
   function new(virtual ram_if.WR_DRV_MP wr_drv_if,
                    mailbox #(ram_trans) gen2wr);
      this.wr_drv_if = wr_drv_if;
      this.gen2wr    = gen2wr;
   endfunction: new

   //drive - drives the transaction to DUT
   virtual task drive();
      @(wr_drv_if.wr_drv_cb);
      wr_drv_if.wr_drv_cb.data_in    <= data2duv.data;
      wr_drv_if.wr_drv_cb.wr_address <= data2duv.wr_address;
      wr_drv_if.wr_drv_cb.write      <= data2duv.write;    
      repeat(2)
         @(wr_drv_if.wr_drv_cb);

      wr_drv_if.wr_drv_cb.write <= '0;
   endtask: drive
   
   //start - collects the transaction from generator
   virtual task start();
      fork
         forever
            begin
               gen2wr.get(data2duv);
               drive();
            end
      join_none
   endtask: start

endclass: ram_write_drv
