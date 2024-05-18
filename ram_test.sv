/********************************************************************************************

Copyright 2019 - Maven Silicon Softech Pvt Ltd.  
www.maven-silicon.com

All Rights Reserved.

This source code is an unpublished work belongs to Maven Silicon Softech Pvt Ltd.
It is not to be shared with or used by any third parties who have not enrolled for our paid 
training courses or received any written authorization from Maven Silicon.

Filename       :  ram_test.sv   

Description    :  Test class for dual port ram_testbench

Author Name    :  Putta Satish   

Support e-mail :  techsupport_vm@maven-silicon.com 

Version        :  1.0

Date           :  02/06/2020

********************************************************************************************/

//Extended Transaction class
class ram_trans_extnd1 extends ram_trans;    
   constraint valid_random_data1 {data inside {[1501:2000],4294};}  
   constraint valid_random_rd {rd_address inside {0,4095};}  
endclass : ram_trans_extnd1

//Extended transaction class
class ram_trans_extnd2 extends ram_trans;    
   constraint valid_random_data2 {data == 4294;}  
endclass : ram_trans_extnd2

class ram_base_test;

   //Virtual interface 
   virtual ram_if.RD_DRV_MP rd_drv_if;
   virtual ram_if.WR_DRV_MP wr_drv_if; 
   virtual ram_if.RD_MON_MP rd_mon_if; 
   virtual ram_if.WR_MON_MP wr_mon_if;

   //Env Handle
   ram_env env_h;
     
   //constructor - Will connect static interface with virtual interface
   //constructs object for Environment
   function new(virtual ram_if.WR_DRV_MP wr_drv_if, 
                virtual ram_if.RD_DRV_MP rd_drv_if,
                virtual ram_if.WR_MON_MP wr_mon_if,
                virtual ram_if.RD_MON_MP rd_mon_if);
      this.wr_drv_if = wr_drv_if;
      this.rd_drv_if = rd_drv_if;
      this.wr_mon_if = wr_mon_if; 
      this.rd_mon_if = rd_mon_if;
      
      env_h = new(wr_drv_if,rd_drv_if,wr_mon_if,rd_mon_if);
   endfunction: new

   //build - builds the TB environment
   virtual task build();
      env_h.build();
   endtask: build
   
   //run - runs the simulation for different testcases
   virtual task run();              
      env_h.run();
   endtask: run   
   
endclass: ram_base_test

class ram_test_extnd1 extends ram_base_test;
      
   //Extended Transaction handle 
   ram_trans_extnd1 data_h1;
   
   //constructor - Will connect static interface with virtual interface
   function new(virtual ram_if.WR_DRV_MP wr_drv_if, 
                virtual ram_if.RD_DRV_MP rd_drv_if,
                virtual ram_if.WR_MON_MP wr_mon_if,
                virtual ram_if.RD_MON_MP rd_mon_if);
      super.new(wr_drv_if,rd_drv_if,wr_mon_if,rd_mon_if);      
   endfunction: new

   //build - builds the TB environment
   virtual task build();
      super.build();
   endtask: build
   
   //run - runs the simulation 
   //constructs extended transaction object
   virtual task run();  
      data_h1 = new();
      env_h.gen_h.gen_trans = data_h1;
      super.run();
   endtask: run      
   
endclass: ram_test_extnd1

class ram_test_extnd2 extends ram_base_test;
      
   //Extended Transaction handle
   ram_trans_extnd2 data_h2;
   
   //constructor - Will connect static interface with virtual interface
   function new(virtual ram_if.WR_DRV_MP wr_drv_if, 
                virtual ram_if.RD_DRV_MP rd_drv_if,
                virtual ram_if.WR_MON_MP wr_mon_if,
                virtual ram_if.RD_MON_MP rd_mon_if);
      super.new(wr_drv_if,rd_drv_if,wr_mon_if,rd_mon_if);      
   endfunction: new

   //build - builds the TB environment
   virtual task build();
      super.build();
   endtask: build
   
   //run - runs the simulation 
   //constructs extended transaction object
   virtual task run();  
      data_h2 = new();
      env_h.gen_h.gen_trans = data_h2;
      super.run();
   endtask: run      
   
endclass: ram_test_extnd2


