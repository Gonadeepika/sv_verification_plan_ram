/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_read_mon.sv   

Description    :  Monitor class for dual port ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

***********************************************************************************************/

class ram_read_mon;

   //Virtual interface 
   virtual ram_if.RD_MON_MP rd_mon_if;

   //Transaction Handles 
   ram_trans rddata;
   ram_trans data2rm;
   ram_trans data2sb;

   //Mailbox Handles
   //Read Monitor to reference Model
   mailbox #(ram_trans) mon2rm;
   //Read Monitor to Scoreboard
   mailbox #(ram_trans) mon2sb;
   
   //constructor - Will connect the static interface with virtual interface
   //connects the mailboxes
   //constructs the transaction object 
   function new(virtual ram_if.RD_MON_MP rd_mon_if,
                     mailbox #(ram_trans) mon2rm,
                     mailbox #(ram_trans) mon2sb);
      this.rd_mon_if = rd_mon_if;
      this.mon2rm    = mon2rm;
      this.mon2sb    = mon2sb;
      this.rddata    = new;
   endfunction: new

   //monitor - samples from DUT 
   virtual task monitor();
      @(rd_mon_if.rd_mon_cb);
      wait (rd_mon_if.rd_mon_cb.read==1);
      @(rd_mon_if.rd_mon_cb);
      begin
         rddata.read = rd_mon_if.rd_mon_cb.read;
         rddata.rd_address = rd_mon_if.rd_mon_cb.rd_address;
         rddata.data_out = rd_mon_if.rd_mon_cb.data_out;
         rddata.display("DATA FROM READ MONITOR");
      end
   endtask: monitor
 
   //start - shallow copy the transaction object
   //puts the transaction into Scoreboard and Reference model mailbox      
   virtual task start();
      fork
         forever
            begin
               monitor(); 
               data2sb = new rddata;
               data2rm = new rddata;
               mon2rm.put(data2rm);
               mon2sb.put(data2sb);
            end
      join_none
   endtask: start

endclass: ram_read_mon
