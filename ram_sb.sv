/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_sb.sv   

Description    :  Scoreboard for dual port ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

********************************************************************************************/

class ram_sb;

   //event declaration
   event DONE; 

   //Fields -to keep track of tansactions received  
   int data_verified = 0;
   int rm_data_count = 0;
   int mon_data_count = 0;

   //Transaction Handles 
   ram_trans rm_data;  
   ram_trans rcvd_data;
   ram_trans cov_data;

   //Mailbox Handles
   //Reference Model to Scoreboard 
   mailbox #(ram_trans) rm2sb;      
   //Read monitor to Scoreboard
   mailbox #(ram_trans) rdmon2sb;   

   //Coverage model 
   covergroup mem_coverage;
      option.per_instance = 1;   
   
      RD_ADD : coverpoint cov_data.rd_address {
                       bins ZERO     = {0};
                       bins LOW1     = {[1:585]};
                       bins LOW2     = {[586:1170]};
                       bins MID_LOW  = {[1171:1755]};
                       bins MID      = {[1756:2340]};
                       bins MID_HIGH = {[2341:2925]};
                       bins HIGH1    = {[2926:3510]};
                       bins HIGH2    = {[3511:4094]};
                       bins MAX      = {4095};
                                              }                                 

      DATA : coverpoint cov_data.data_out {
                       bins ZERO     = {0};
                       bins LOW1     = {[1:500]};
                       bins LOW2     = {[501:1000]};
                       bins MID_LOW  = {[1001:1500]};
                       bins MID      = {[1501:2000]};
                       bins MID_HIGH = {[2001:2500]};
                       bins HIGH1    = {[2501:3000]};
                       bins HIGH2    = {[3000:4293]};
                       bins MAX      = {4294};
                                          }     
      
      RD : coverpoint cov_data.read {
                       bins read     = {1};
                                    }

      READxADD: cross RD,RD_ADD; 

   endgroup : mem_coverage

   //constructor - Will connect the mailboxes
   //construct the covergroup object
   function new(mailbox #(ram_trans) rm2sb,
                mailbox #(ram_trans) rdmon2sb);
      this.rm2sb    = rm2sb;
      this.rdmon2sb = rdmon2sb;
      mem_coverage  = new;    
   endfunction: new

   //start - collects the transactions from Reference model and Scoreboard 
   virtual task start();
      fork
         while(1)
            begin
               rm2sb.get(rm_data);
               rm_data_count++;

               rdmon2sb.get(rcvd_data);   
               mon_data_count++;    
      
               check(rcvd_data);
            end
      join_none
   endtask: start

   //check - compares the transactions
   //samples the coverage
   //triggeres the event
   virtual task check(ram_trans rc_data);
      string diff;
      if(rc_data.read == 1) 
         begin
            if(rc_data.data_out == 0)
               $display("SB: Random data not written");
            else if(rc_data.read == 1 && rc_data.data_out != 0)
               begin
                  if(!rm_data.compare(rc_data,diff))
                     begin:failed_compare
                        rc_data.display("SB: Received Data");
                        rm_data.display("SB: Data sent to DUV");
                        $display("%s\n%m\n\n", diff);
                        $finish;
                     end:failed_compare
                  else
                     $display("SB:  %s\n%m\n\n", diff);
               end
            cov_data = new rm_data;
            mem_coverage.sample();
  
            data_verified++;
            if(data_verified >= (number_of_transactions-rc_data.no_of_write_trans)) 
               begin
                  ->DONE;
               end
         end
   endtask: check

   //report - scoreboard report after comparing the transaction
   virtual function void report();
      $display(" ------------------------ SCOREBOARD REPORT ------------------------- \n ");
      $display(" %0d Read Data Generated, %0d Read Data Recevied, %0d Read Data Verified \n",
                                                rm_data_count,mon_data_count,data_verified);
      $display(" -------------------------------------------------------------------- \n ");
   endfunction: report
    
endclass: ram_sb
