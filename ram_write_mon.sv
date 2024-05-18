/********************************************************************************************
Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_write_mon.sv   

Description    :  Monitor for dual port ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

***********************************************************************************************/

class ram_write_mon;

   //Virtual interface 
   virtual ram_if.WR_MON_MP wr_mon_if;

   //Transaction Handles
   ram_trans wrdata;
   ram_trans data2rm;

   //Mailbox Handle
   //Write monitor to Reference Model
   mailbox #(ram_trans) mon2rm;
   
   //constructor - Will connect the static interface with the virtual interface 
   //connects the mailbox  
   //constructs the transaction object 
   function new(virtual ram_if.WR_MON_MP wr_mon_if,
                   mailbox #(ram_trans) mon2rm);
      this.wr_mon_if = wr_mon_if;
      this.mon2rm    = mon2rm;
      this.wrdata    = new;
   endfunction: new

   //monitor - samples from DUT
   virtual task monitor();
      @(wr_mon_if.wr_mon_cb)
      wait(wr_mon_if.wr_mon_cb.write==1) 
      @(wr_mon_if.wr_mon_cb);
      begin
         wrdata.write= wr_mon_if.wr_mon_cb.write;
         wrdata.wr_address =  wr_mon_if.wr_mon_cb.wr_address;
         wrdata.data= wr_mon_if.wr_mon_cb.data_in;
         wrdata.display("DATA FROM WRITE MONITOR");
      end
   endtask: monitor
   
   //start - shallow copy the transaction object
   //puts the transaction to reference model mailbox           
   virtual task start();
      fork
         forever
            begin
               monitor(); 
               data2rm = new wrdata;
               mon2rm.put(data2rm);
            end
      join_none
   endtask: start

endclass:ram_write_mon
