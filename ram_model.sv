/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_model.sv   

Description    :  Reference Model for ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

*********************************************************************************************/

class ram_model;

   //Transaction Handles
   ram_trans wrmon_data;
   ram_trans rdmon_data;

   //Associative array  
   logic [63:0] ref_data[int];

   //Mailbox Handles
   //Write Monitor to Reference Model  
   mailbox #(ram_trans) wr2rm;
   //Read Monitor to Reference Model
   mailbox #(ram_trans) rd2rm;
   //Reference Model to Scoreboard
   mailbox #(ram_trans) rm2sb;

   //constructor - Will connect the mailboxes
   function new(mailbox #(ram_trans) wr2rm,
                mailbox #(ram_trans) rd2rm,
                mailbox #(ram_trans) rm2sb);
      this.wr2rm = wr2rm;
      this.rd2rm = rd2rm;
      this.rm2sb = rm2sb;
   endfunction: new
   
   //mem_write - Writes into Associative array
   //mem_read - Reads from Associative array
   virtual task dual_mem_fun_write(ram_trans wrmon_data);
      begin
         if(wrmon_data.write)
            mem_write(wrmon_data);
      end
   endtask: dual_mem_fun_write

   virtual task dual_mem_fun_read(ram_trans rdmon_data);
      begin
         if(rdmon_data.read)
            mem_read(rdmon_data);
      end
   endtask: dual_mem_fun_read

   virtual task mem_write(ram_trans wrmon_data);
      ref_data[wrmon_data.wr_address]= wrmon_data.data;
   endtask: mem_write

   virtual task mem_read(inout ram_trans rdmon_data);
      if(ref_data.exists(rdmon_data.rd_address))   
         rdmon_data.data_out = ref_data[rdmon_data.rd_address];
   endtask: mem_read

   //start - collects the transaction from both the monitors
   //puts the transaction into the scoreboard mailbox
   virtual task start();
      fork
         begin
            fork
               begin
                  forever 
                     begin
                        wr2rm.get(wrmon_data);
                        dual_mem_fun_write(wrmon_data);
                     end
               end

               begin
                  forever
                     begin
                        rd2rm.get(rdmon_data);
                        dual_mem_fun_read(rdmon_data);
                        rm2sb.put(rdmon_data);
                     end
               end
            join
         end
      join_none
   endtask: start

endclass: ram_model
