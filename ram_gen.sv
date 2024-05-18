/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_gen.sv   

Description    :  Generator class for Dual Port Ram Testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

*********************************************************************************************/

class ram_gen;

   //Transaction Handles
   ram_trans gen_trans;
   ram_trans data2send;

   //Mailbox Handles 
   //Generator to Read Driver
   mailbox #(ram_trans) gen2rd;
   //Generator to Write Driver
   mailbox #(ram_trans) gen2wr;
 
   //constructor - Will connect the mailboxes and construct the transaction handle
   function new(mailbox #(ram_trans)gen2rd,
                mailbox #(ram_trans)gen2wr);
      this.gen_trans = new;
      this.gen2rd    = gen2rd;
      this.gen2wr    = gen2wr;
   endfunction: new

   //start - Generates the transactions
   //shallow copy the randomized transaction object
   //puts the transaction into drivers mailboxes
   virtual task start();
      fork
         begin
            for(int i=0; i<number_of_transactions; i++)
               begin       
                  gen_trans.randomize();
                  data2send = new gen_trans;
                  gen2rd.put(data2send);
                  gen2wr.put(data2send);
               end
         end
      join_none
   endtask: start

endclass: ram_gen
   
      
 


