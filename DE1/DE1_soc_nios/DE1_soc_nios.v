//megafunction wizard: %Altera SOPC Builder%
//GENERATION: STANDARD
//VERSION: WM1.0


//Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_jtag_debug_module_arbitrator (
                                          // inputs:
                                           clk,
                                           cpu_data_master_address_to_slave,
                                           cpu_data_master_byteenable,
                                           cpu_data_master_debugaccess,
                                           cpu_data_master_read,
                                           cpu_data_master_waitrequest,
                                           cpu_data_master_write,
                                           cpu_data_master_writedata,
                                           cpu_instruction_master_address_to_slave,
                                           cpu_instruction_master_read,
                                           cpu_jtag_debug_module_readdata,
                                           cpu_jtag_debug_module_resetrequest,
                                           reset_n,

                                          // outputs:
                                           cpu_data_master_granted_cpu_jtag_debug_module,
                                           cpu_data_master_qualified_request_cpu_jtag_debug_module,
                                           cpu_data_master_read_data_valid_cpu_jtag_debug_module,
                                           cpu_data_master_requests_cpu_jtag_debug_module,
                                           cpu_instruction_master_granted_cpu_jtag_debug_module,
                                           cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
                                           cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
                                           cpu_instruction_master_requests_cpu_jtag_debug_module,
                                           cpu_jtag_debug_module_address,
                                           cpu_jtag_debug_module_begintransfer,
                                           cpu_jtag_debug_module_byteenable,
                                           cpu_jtag_debug_module_chipselect,
                                           cpu_jtag_debug_module_debugaccess,
                                           cpu_jtag_debug_module_readdata_from_sa,
                                           cpu_jtag_debug_module_reset_n,
                                           cpu_jtag_debug_module_resetrequest_from_sa,
                                           cpu_jtag_debug_module_write,
                                           cpu_jtag_debug_module_writedata,
                                           d1_cpu_jtag_debug_module_end_xfer
                                        )
;

  output           cpu_data_master_granted_cpu_jtag_debug_module;
  output           cpu_data_master_qualified_request_cpu_jtag_debug_module;
  output           cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  output           cpu_data_master_requests_cpu_jtag_debug_module;
  output           cpu_instruction_master_granted_cpu_jtag_debug_module;
  output           cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  output           cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  output           cpu_instruction_master_requests_cpu_jtag_debug_module;
  output  [  8: 0] cpu_jtag_debug_module_address;
  output           cpu_jtag_debug_module_begintransfer;
  output  [  3: 0] cpu_jtag_debug_module_byteenable;
  output           cpu_jtag_debug_module_chipselect;
  output           cpu_jtag_debug_module_debugaccess;
  output  [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  output           cpu_jtag_debug_module_reset_n;
  output           cpu_jtag_debug_module_resetrequest_from_sa;
  output           cpu_jtag_debug_module_write;
  output  [ 31: 0] cpu_jtag_debug_module_writedata;
  output           d1_cpu_jtag_debug_module_end_xfer;
  input            clk;
  input   [ 18: 0] cpu_data_master_address_to_slave;
  input   [  3: 0] cpu_data_master_byteenable;
  input            cpu_data_master_debugaccess;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 18: 0] cpu_instruction_master_address_to_slave;
  input            cpu_instruction_master_read;
  input   [ 31: 0] cpu_jtag_debug_module_readdata;
  input            cpu_jtag_debug_module_resetrequest;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_cpu_jtag_debug_module;
  wire             cpu_data_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_data_master_requests_cpu_jtag_debug_module;
  wire             cpu_data_master_saved_grant_cpu_jtag_debug_module;
  wire             cpu_instruction_master_arbiterlock;
  wire             cpu_instruction_master_arbiterlock2;
  wire             cpu_instruction_master_continuerequest;
  wire             cpu_instruction_master_granted_cpu_jtag_debug_module;
  wire             cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_instruction_master_requests_cpu_jtag_debug_module;
  wire             cpu_instruction_master_saved_grant_cpu_jtag_debug_module;
  wire    [  8: 0] cpu_jtag_debug_module_address;
  wire             cpu_jtag_debug_module_allgrants;
  wire             cpu_jtag_debug_module_allow_new_arb_cycle;
  wire             cpu_jtag_debug_module_any_bursting_master_saved_grant;
  wire             cpu_jtag_debug_module_any_continuerequest;
  reg     [  1: 0] cpu_jtag_debug_module_arb_addend;
  wire             cpu_jtag_debug_module_arb_counter_enable;
  reg              cpu_jtag_debug_module_arb_share_counter;
  wire             cpu_jtag_debug_module_arb_share_counter_next_value;
  wire             cpu_jtag_debug_module_arb_share_set_values;
  wire    [  1: 0] cpu_jtag_debug_module_arb_winner;
  wire             cpu_jtag_debug_module_arbitration_holdoff_internal;
  wire             cpu_jtag_debug_module_beginbursttransfer_internal;
  wire             cpu_jtag_debug_module_begins_xfer;
  wire             cpu_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_jtag_debug_module_byteenable;
  wire             cpu_jtag_debug_module_chipselect;
  wire    [  3: 0] cpu_jtag_debug_module_chosen_master_double_vector;
  wire    [  1: 0] cpu_jtag_debug_module_chosen_master_rot_left;
  wire             cpu_jtag_debug_module_debugaccess;
  wire             cpu_jtag_debug_module_end_xfer;
  wire             cpu_jtag_debug_module_firsttransfer;
  wire    [  1: 0] cpu_jtag_debug_module_grant_vector;
  wire             cpu_jtag_debug_module_in_a_read_cycle;
  wire             cpu_jtag_debug_module_in_a_write_cycle;
  wire    [  1: 0] cpu_jtag_debug_module_master_qreq_vector;
  wire             cpu_jtag_debug_module_non_bursting_master_requests;
  wire    [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  reg              cpu_jtag_debug_module_reg_firsttransfer;
  wire             cpu_jtag_debug_module_reset_n;
  wire             cpu_jtag_debug_module_resetrequest_from_sa;
  reg     [  1: 0] cpu_jtag_debug_module_saved_chosen_master_vector;
  reg              cpu_jtag_debug_module_slavearbiterlockenable;
  wire             cpu_jtag_debug_module_slavearbiterlockenable2;
  wire             cpu_jtag_debug_module_unreg_firsttransfer;
  wire             cpu_jtag_debug_module_waits_for_read;
  wire             cpu_jtag_debug_module_waits_for_write;
  wire             cpu_jtag_debug_module_write;
  wire    [ 31: 0] cpu_jtag_debug_module_writedata;
  reg              d1_cpu_jtag_debug_module_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_cpu_jtag_debug_module;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module;
  reg              last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module;
  wire    [ 18: 0] shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master;
  wire    [ 18: 0] shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master;
  wire             wait_for_cpu_jtag_debug_module_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~cpu_jtag_debug_module_end_xfer;
    end


  assign cpu_jtag_debug_module_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_cpu_jtag_debug_module | cpu_instruction_master_qualified_request_cpu_jtag_debug_module));
  //assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata;

  assign cpu_data_master_requests_cpu_jtag_debug_module = ({cpu_data_master_address_to_slave[18 : 11] , 11'b0} == 19'h40800) & (cpu_data_master_read | cpu_data_master_write);
  //cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  assign cpu_jtag_debug_module_arb_share_set_values = 1;

  //cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  assign cpu_jtag_debug_module_non_bursting_master_requests = cpu_data_master_requests_cpu_jtag_debug_module |
    cpu_instruction_master_requests_cpu_jtag_debug_module |
    cpu_data_master_requests_cpu_jtag_debug_module |
    cpu_instruction_master_requests_cpu_jtag_debug_module;

  //cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  assign cpu_jtag_debug_module_any_bursting_master_saved_grant = 0;

  //cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  assign cpu_jtag_debug_module_arb_share_counter_next_value = cpu_jtag_debug_module_firsttransfer ? (cpu_jtag_debug_module_arb_share_set_values - 1) : |cpu_jtag_debug_module_arb_share_counter ? (cpu_jtag_debug_module_arb_share_counter - 1) : 0;

  //cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  assign cpu_jtag_debug_module_allgrants = (|cpu_jtag_debug_module_grant_vector) |
    (|cpu_jtag_debug_module_grant_vector) |
    (|cpu_jtag_debug_module_grant_vector) |
    (|cpu_jtag_debug_module_grant_vector);

  //cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  assign cpu_jtag_debug_module_end_xfer = ~(cpu_jtag_debug_module_waits_for_read | cpu_jtag_debug_module_waits_for_write);

  //end_xfer_arb_share_counter_term_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_cpu_jtag_debug_module = cpu_jtag_debug_module_end_xfer & (~cpu_jtag_debug_module_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  assign cpu_jtag_debug_module_arb_counter_enable = (end_xfer_arb_share_counter_term_cpu_jtag_debug_module & cpu_jtag_debug_module_allgrants) | (end_xfer_arb_share_counter_term_cpu_jtag_debug_module & ~cpu_jtag_debug_module_non_bursting_master_requests);

  //cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_arb_share_counter <= 0;
      else if (cpu_jtag_debug_module_arb_counter_enable)
          cpu_jtag_debug_module_arb_share_counter <= cpu_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_slavearbiterlockenable <= 0;
      else if ((|cpu_jtag_debug_module_master_qreq_vector & end_xfer_arb_share_counter_term_cpu_jtag_debug_module) | (end_xfer_arb_share_counter_term_cpu_jtag_debug_module & ~cpu_jtag_debug_module_non_bursting_master_requests))
          cpu_jtag_debug_module_slavearbiterlockenable <= |cpu_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu/data_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = cpu_jtag_debug_module_slavearbiterlockenable & cpu_data_master_continuerequest;

  //cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign cpu_jtag_debug_module_slavearbiterlockenable2 = |cpu_jtag_debug_module_arb_share_counter_next_value;

  //cpu/data_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = cpu_jtag_debug_module_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //cpu/instruction_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_instruction_master_arbiterlock = cpu_jtag_debug_module_slavearbiterlockenable & cpu_instruction_master_continuerequest;

  //cpu/instruction_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_instruction_master_arbiterlock2 = cpu_jtag_debug_module_slavearbiterlockenable2 & cpu_instruction_master_continuerequest;

  //cpu/instruction_master granted cpu/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= cpu_instruction_master_saved_grant_cpu_jtag_debug_module ? 1 : (cpu_jtag_debug_module_arbitration_holdoff_internal | ~cpu_instruction_master_requests_cpu_jtag_debug_module) ? 0 : last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module;
    end


  //cpu_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_instruction_master_continuerequest = last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module & cpu_instruction_master_requests_cpu_jtag_debug_module;

  //cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  assign cpu_jtag_debug_module_any_continuerequest = cpu_instruction_master_continuerequest |
    cpu_data_master_continuerequest;

  assign cpu_data_master_qualified_request_cpu_jtag_debug_module = cpu_data_master_requests_cpu_jtag_debug_module & ~(((~cpu_data_master_waitrequest) & cpu_data_master_write) | cpu_instruction_master_arbiterlock);
  //cpu_jtag_debug_module_writedata mux, which is an e_mux
  assign cpu_jtag_debug_module_writedata = cpu_data_master_writedata;

  assign cpu_instruction_master_requests_cpu_jtag_debug_module = (({cpu_instruction_master_address_to_slave[18 : 11] , 11'b0} == 19'h40800) & (cpu_instruction_master_read)) & cpu_instruction_master_read;
  //cpu/data_master granted cpu/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= cpu_data_master_saved_grant_cpu_jtag_debug_module ? 1 : (cpu_jtag_debug_module_arbitration_holdoff_internal | ~cpu_data_master_requests_cpu_jtag_debug_module) ? 0 : last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module;
    end


  //cpu_data_master_continuerequest continued request, which is an e_mux
  assign cpu_data_master_continuerequest = last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module & cpu_data_master_requests_cpu_jtag_debug_module;

  assign cpu_instruction_master_qualified_request_cpu_jtag_debug_module = cpu_instruction_master_requests_cpu_jtag_debug_module & ~(cpu_data_master_arbiterlock);
  //allow new arb cycle for cpu/jtag_debug_module, which is an e_assign
  assign cpu_jtag_debug_module_allow_new_arb_cycle = ~cpu_data_master_arbiterlock & ~cpu_instruction_master_arbiterlock;

  //cpu/instruction_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  assign cpu_jtag_debug_module_master_qreq_vector[0] = cpu_instruction_master_qualified_request_cpu_jtag_debug_module;

  //cpu/instruction_master grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_instruction_master_granted_cpu_jtag_debug_module = cpu_jtag_debug_module_grant_vector[0];

  //cpu/instruction_master saved-grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_instruction_master_saved_grant_cpu_jtag_debug_module = cpu_jtag_debug_module_arb_winner[0] && cpu_instruction_master_requests_cpu_jtag_debug_module;

  //cpu/data_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  assign cpu_jtag_debug_module_master_qreq_vector[1] = cpu_data_master_qualified_request_cpu_jtag_debug_module;

  //cpu/data_master grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_data_master_granted_cpu_jtag_debug_module = cpu_jtag_debug_module_grant_vector[1];

  //cpu/data_master saved-grant cpu/jtag_debug_module, which is an e_assign
  assign cpu_data_master_saved_grant_cpu_jtag_debug_module = cpu_jtag_debug_module_arb_winner[1] && cpu_data_master_requests_cpu_jtag_debug_module;

  //cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  assign cpu_jtag_debug_module_chosen_master_double_vector = {cpu_jtag_debug_module_master_qreq_vector, cpu_jtag_debug_module_master_qreq_vector} & ({~cpu_jtag_debug_module_master_qreq_vector, ~cpu_jtag_debug_module_master_qreq_vector} + cpu_jtag_debug_module_arb_addend);

  //stable onehot encoding of arb winner
  assign cpu_jtag_debug_module_arb_winner = (cpu_jtag_debug_module_allow_new_arb_cycle & | cpu_jtag_debug_module_grant_vector) ? cpu_jtag_debug_module_grant_vector : cpu_jtag_debug_module_saved_chosen_master_vector;

  //saved cpu_jtag_debug_module_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_saved_chosen_master_vector <= 0;
      else if (cpu_jtag_debug_module_allow_new_arb_cycle)
          cpu_jtag_debug_module_saved_chosen_master_vector <= |cpu_jtag_debug_module_grant_vector ? cpu_jtag_debug_module_grant_vector : cpu_jtag_debug_module_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign cpu_jtag_debug_module_grant_vector = {(cpu_jtag_debug_module_chosen_master_double_vector[1] | cpu_jtag_debug_module_chosen_master_double_vector[3]),
    (cpu_jtag_debug_module_chosen_master_double_vector[0] | cpu_jtag_debug_module_chosen_master_double_vector[2])};

  //cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  assign cpu_jtag_debug_module_chosen_master_rot_left = (cpu_jtag_debug_module_arb_winner << 1) ? (cpu_jtag_debug_module_arb_winner << 1) : 1;

  //cpu/jtag_debug_module's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_arb_addend <= 1;
      else if (|cpu_jtag_debug_module_grant_vector)
          cpu_jtag_debug_module_arb_addend <= cpu_jtag_debug_module_end_xfer? cpu_jtag_debug_module_chosen_master_rot_left : cpu_jtag_debug_module_grant_vector;
    end


  assign cpu_jtag_debug_module_begintransfer = cpu_jtag_debug_module_begins_xfer;
  //cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  assign cpu_jtag_debug_module_reset_n = reset_n;

  //assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest;

  assign cpu_jtag_debug_module_chipselect = cpu_data_master_granted_cpu_jtag_debug_module | cpu_instruction_master_granted_cpu_jtag_debug_module;
  //cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  assign cpu_jtag_debug_module_firsttransfer = cpu_jtag_debug_module_begins_xfer ? cpu_jtag_debug_module_unreg_firsttransfer : cpu_jtag_debug_module_reg_firsttransfer;

  //cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  assign cpu_jtag_debug_module_unreg_firsttransfer = ~(cpu_jtag_debug_module_slavearbiterlockenable & cpu_jtag_debug_module_any_continuerequest);

  //cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_jtag_debug_module_reg_firsttransfer <= 1'b1;
      else if (cpu_jtag_debug_module_begins_xfer)
          cpu_jtag_debug_module_reg_firsttransfer <= cpu_jtag_debug_module_unreg_firsttransfer;
    end


  //cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign cpu_jtag_debug_module_beginbursttransfer_internal = cpu_jtag_debug_module_begins_xfer;

  //cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign cpu_jtag_debug_module_arbitration_holdoff_internal = cpu_jtag_debug_module_begins_xfer & cpu_jtag_debug_module_firsttransfer;

  //cpu_jtag_debug_module_write assignment, which is an e_mux
  assign cpu_jtag_debug_module_write = cpu_data_master_granted_cpu_jtag_debug_module & cpu_data_master_write;

  assign shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master = cpu_data_master_address_to_slave;
  //cpu_jtag_debug_module_address mux, which is an e_mux
  assign cpu_jtag_debug_module_address = (cpu_data_master_granted_cpu_jtag_debug_module)? (shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master >> 2) :
    (shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master >> 2);

  assign shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master = cpu_instruction_master_address_to_slave;
  //d1_cpu_jtag_debug_module_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_cpu_jtag_debug_module_end_xfer <= 1;
      else 
        d1_cpu_jtag_debug_module_end_xfer <= cpu_jtag_debug_module_end_xfer;
    end


  //cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  assign cpu_jtag_debug_module_waits_for_read = cpu_jtag_debug_module_in_a_read_cycle & cpu_jtag_debug_module_begins_xfer;

  //cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  assign cpu_jtag_debug_module_in_a_read_cycle = (cpu_data_master_granted_cpu_jtag_debug_module & cpu_data_master_read) | (cpu_instruction_master_granted_cpu_jtag_debug_module & cpu_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = cpu_jtag_debug_module_in_a_read_cycle;

  //cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  assign cpu_jtag_debug_module_waits_for_write = cpu_jtag_debug_module_in_a_write_cycle & 0;

  //cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  assign cpu_jtag_debug_module_in_a_write_cycle = cpu_data_master_granted_cpu_jtag_debug_module & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = cpu_jtag_debug_module_in_a_write_cycle;

  assign wait_for_cpu_jtag_debug_module_counter = 0;
  //cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  assign cpu_jtag_debug_module_byteenable = (cpu_data_master_granted_cpu_jtag_debug_module)? cpu_data_master_byteenable :
    -1;

  //debugaccess mux, which is an e_mux
  assign cpu_jtag_debug_module_debugaccess = (cpu_data_master_granted_cpu_jtag_debug_module)? cpu_data_master_debugaccess :
    0;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu/jtag_debug_module enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_granted_cpu_jtag_debug_module + cpu_instruction_master_granted_cpu_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_saved_grant_cpu_jtag_debug_module + cpu_instruction_master_saved_grant_cpu_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_data_master_arbitrator (
                                    // inputs:
                                     clk,
                                     cpu_data_master_address,
                                     cpu_data_master_granted_cpu_jtag_debug_module,
                                     cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_granted_onchip_memory_s1,
                                     cpu_data_master_granted_stopwatch_i_avalon_slave,
                                     cpu_data_master_granted_uart_i_avalon_slave,
                                     cpu_data_master_qualified_request_cpu_jtag_debug_module,
                                     cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_qualified_request_onchip_memory_s1,
                                     cpu_data_master_qualified_request_stopwatch_i_avalon_slave,
                                     cpu_data_master_qualified_request_uart_i_avalon_slave,
                                     cpu_data_master_read,
                                     cpu_data_master_read_data_valid_cpu_jtag_debug_module,
                                     cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_read_data_valid_onchip_memory_s1,
                                     cpu_data_master_read_data_valid_stopwatch_i_avalon_slave,
                                     cpu_data_master_read_data_valid_uart_i_avalon_slave,
                                     cpu_data_master_requests_cpu_jtag_debug_module,
                                     cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
                                     cpu_data_master_requests_onchip_memory_s1,
                                     cpu_data_master_requests_stopwatch_i_avalon_slave,
                                     cpu_data_master_requests_uart_i_avalon_slave,
                                     cpu_data_master_write,
                                     cpu_jtag_debug_module_readdata_from_sa,
                                     d1_cpu_jtag_debug_module_end_xfer,
                                     d1_jtag_uart_avalon_jtag_slave_end_xfer,
                                     d1_onchip_memory_s1_end_xfer,
                                     d1_stopwatch_i_avalon_slave_end_xfer,
                                     d1_uart_i_avalon_slave_end_xfer,
                                     jtag_uart_avalon_jtag_slave_irq_from_sa,
                                     jtag_uart_avalon_jtag_slave_readdata_from_sa,
                                     jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
                                     onchip_memory_s1_readdata_from_sa,
                                     registered_cpu_data_master_read_data_valid_onchip_memory_s1,
                                     reset_n,
                                     stopwatch_i_avalon_slave_irq_from_sa,
                                     stopwatch_i_avalon_slave_readdata_from_sa,
                                     uart_i_avalon_slave_irq_from_sa,
                                     uart_i_avalon_slave_readdata_from_sa,
                                     uart_i_avalon_slave_waitrequest_from_sa,

                                    // outputs:
                                     cpu_data_master_address_to_slave,
                                     cpu_data_master_irq,
                                     cpu_data_master_readdata,
                                     cpu_data_master_waitrequest
                                  )
;

  output  [ 18: 0] cpu_data_master_address_to_slave;
  output  [ 31: 0] cpu_data_master_irq;
  output  [ 31: 0] cpu_data_master_readdata;
  output           cpu_data_master_waitrequest;
  input            clk;
  input   [ 18: 0] cpu_data_master_address;
  input            cpu_data_master_granted_cpu_jtag_debug_module;
  input            cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_granted_onchip_memory_s1;
  input            cpu_data_master_granted_stopwatch_i_avalon_slave;
  input            cpu_data_master_granted_uart_i_avalon_slave;
  input            cpu_data_master_qualified_request_cpu_jtag_debug_module;
  input            cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_qualified_request_onchip_memory_s1;
  input            cpu_data_master_qualified_request_stopwatch_i_avalon_slave;
  input            cpu_data_master_qualified_request_uart_i_avalon_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  input            cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_read_data_valid_onchip_memory_s1;
  input            cpu_data_master_read_data_valid_stopwatch_i_avalon_slave;
  input            cpu_data_master_read_data_valid_uart_i_avalon_slave;
  input            cpu_data_master_requests_cpu_jtag_debug_module;
  input            cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  input            cpu_data_master_requests_onchip_memory_s1;
  input            cpu_data_master_requests_stopwatch_i_avalon_slave;
  input            cpu_data_master_requests_uart_i_avalon_slave;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  input            d1_cpu_jtag_debug_module_end_xfer;
  input            d1_jtag_uart_avalon_jtag_slave_end_xfer;
  input            d1_onchip_memory_s1_end_xfer;
  input            d1_stopwatch_i_avalon_slave_end_xfer;
  input            d1_uart_i_avalon_slave_end_xfer;
  input            jtag_uart_avalon_jtag_slave_irq_from_sa;
  input   [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  input            jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  input   [ 31: 0] onchip_memory_s1_readdata_from_sa;
  input            registered_cpu_data_master_read_data_valid_onchip_memory_s1;
  input            reset_n;
  input            stopwatch_i_avalon_slave_irq_from_sa;
  input   [ 31: 0] stopwatch_i_avalon_slave_readdata_from_sa;
  input            uart_i_avalon_slave_irq_from_sa;
  input   [ 31: 0] uart_i_avalon_slave_readdata_from_sa;
  input            uart_i_avalon_slave_waitrequest_from_sa;

  wire    [ 18: 0] cpu_data_master_address_to_slave;
  wire    [ 31: 0] cpu_data_master_irq;
  wire    [ 31: 0] cpu_data_master_readdata;
  wire             cpu_data_master_run;
  reg              cpu_data_master_waitrequest;
  wire    [ 31: 0] p1_registered_cpu_data_master_readdata;
  wire             r_0;
  wire             r_1;
  reg     [ 31: 0] registered_cpu_data_master_readdata;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_data_master_qualified_request_cpu_jtag_debug_module | ~cpu_data_master_requests_cpu_jtag_debug_module) & (cpu_data_master_granted_cpu_jtag_debug_module | ~cpu_data_master_qualified_request_cpu_jtag_debug_module) & ((~cpu_data_master_qualified_request_cpu_jtag_debug_module | ~cpu_data_master_read | (1 & 1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_cpu_jtag_debug_module | ~cpu_data_master_write | (1 & cpu_data_master_write))) & 1 & (cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave | ~cpu_data_master_requests_jtag_uart_avalon_jtag_slave) & ((~cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & ~jtag_uart_avalon_jtag_slave_waitrequest_from_sa & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & ~jtag_uart_avalon_jtag_slave_waitrequest_from_sa & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_onchip_memory_s1 | registered_cpu_data_master_read_data_valid_onchip_memory_s1 | ~cpu_data_master_requests_onchip_memory_s1) & (cpu_data_master_granted_onchip_memory_s1 | ~cpu_data_master_qualified_request_onchip_memory_s1) & ((~cpu_data_master_qualified_request_onchip_memory_s1 | ~cpu_data_master_read | (registered_cpu_data_master_read_data_valid_onchip_memory_s1 & cpu_data_master_read))) & ((~cpu_data_master_qualified_request_onchip_memory_s1 | ~(cpu_data_master_read | cpu_data_master_write) | (1 & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_stopwatch_i_avalon_slave | ~cpu_data_master_requests_stopwatch_i_avalon_slave) & ((~cpu_data_master_qualified_request_stopwatch_i_avalon_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_stopwatch_i_avalon_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & (cpu_data_master_read | cpu_data_master_write)))) & 1 & (cpu_data_master_qualified_request_uart_i_avalon_slave | ~cpu_data_master_requests_uart_i_avalon_slave);

  //cascaded wait assignment, which is an e_assign
  assign cpu_data_master_run = r_0 & r_1;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = ((~cpu_data_master_qualified_request_uart_i_avalon_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & ~uart_i_avalon_slave_waitrequest_from_sa & (cpu_data_master_read | cpu_data_master_write)))) & ((~cpu_data_master_qualified_request_uart_i_avalon_slave | ~(cpu_data_master_read | cpu_data_master_write) | (1 & ~uart_i_avalon_slave_waitrequest_from_sa & (cpu_data_master_read | cpu_data_master_write))));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_data_master_address_to_slave = cpu_data_master_address[18 : 0];

  //cpu/data_master readdata mux, which is an e_mux
  assign cpu_data_master_readdata = ({32 {~cpu_data_master_requests_cpu_jtag_debug_module}} | cpu_jtag_debug_module_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_jtag_uart_avalon_jtag_slave}} | registered_cpu_data_master_readdata) &
    ({32 {~cpu_data_master_requests_onchip_memory_s1}} | onchip_memory_s1_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_stopwatch_i_avalon_slave}} | registered_cpu_data_master_readdata) &
    ({32 {~cpu_data_master_requests_uart_i_avalon_slave}} | registered_cpu_data_master_readdata);

  //actual waitrequest port, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_data_master_waitrequest <= ~0;
      else 
        cpu_data_master_waitrequest <= ~((~(cpu_data_master_read | cpu_data_master_write))? 0: (cpu_data_master_run & cpu_data_master_waitrequest));
    end


  //unpredictable registered wait state incoming data, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          registered_cpu_data_master_readdata <= 0;
      else 
        registered_cpu_data_master_readdata <= p1_registered_cpu_data_master_readdata;
    end


  //registered readdata mux, which is an e_mux
  assign p1_registered_cpu_data_master_readdata = ({32 {~cpu_data_master_requests_jtag_uart_avalon_jtag_slave}} | jtag_uart_avalon_jtag_slave_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_stopwatch_i_avalon_slave}} | stopwatch_i_avalon_slave_readdata_from_sa) &
    ({32 {~cpu_data_master_requests_uart_i_avalon_slave}} | uart_i_avalon_slave_readdata_from_sa);

  //irq assign, which is an e_assign
  assign cpu_data_master_irq = {1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    uart_i_avalon_slave_irq_from_sa,
    stopwatch_i_avalon_slave_irq_from_sa,
    jtag_uart_avalon_jtag_slave_irq_from_sa};


endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_instruction_master_arbitrator (
                                           // inputs:
                                            clk,
                                            cpu_instruction_master_address,
                                            cpu_instruction_master_granted_cpu_jtag_debug_module,
                                            cpu_instruction_master_granted_onchip_memory_s1,
                                            cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
                                            cpu_instruction_master_qualified_request_onchip_memory_s1,
                                            cpu_instruction_master_read,
                                            cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
                                            cpu_instruction_master_read_data_valid_onchip_memory_s1,
                                            cpu_instruction_master_requests_cpu_jtag_debug_module,
                                            cpu_instruction_master_requests_onchip_memory_s1,
                                            cpu_jtag_debug_module_readdata_from_sa,
                                            d1_cpu_jtag_debug_module_end_xfer,
                                            d1_onchip_memory_s1_end_xfer,
                                            onchip_memory_s1_readdata_from_sa,
                                            reset_n,

                                           // outputs:
                                            cpu_instruction_master_address_to_slave,
                                            cpu_instruction_master_readdata,
                                            cpu_instruction_master_waitrequest
                                         )
;

  output  [ 18: 0] cpu_instruction_master_address_to_slave;
  output  [ 31: 0] cpu_instruction_master_readdata;
  output           cpu_instruction_master_waitrequest;
  input            clk;
  input   [ 18: 0] cpu_instruction_master_address;
  input            cpu_instruction_master_granted_cpu_jtag_debug_module;
  input            cpu_instruction_master_granted_onchip_memory_s1;
  input            cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  input            cpu_instruction_master_qualified_request_onchip_memory_s1;
  input            cpu_instruction_master_read;
  input            cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  input            cpu_instruction_master_read_data_valid_onchip_memory_s1;
  input            cpu_instruction_master_requests_cpu_jtag_debug_module;
  input            cpu_instruction_master_requests_onchip_memory_s1;
  input   [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  input            d1_cpu_jtag_debug_module_end_xfer;
  input            d1_onchip_memory_s1_end_xfer;
  input   [ 31: 0] onchip_memory_s1_readdata_from_sa;
  input            reset_n;

  reg              active_and_waiting_last_time;
  reg     [ 18: 0] cpu_instruction_master_address_last_time;
  wire    [ 18: 0] cpu_instruction_master_address_to_slave;
  reg              cpu_instruction_master_read_last_time;
  wire    [ 31: 0] cpu_instruction_master_readdata;
  wire             cpu_instruction_master_run;
  wire             cpu_instruction_master_waitrequest;
  wire             r_0;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_instruction_master_qualified_request_cpu_jtag_debug_module | ~cpu_instruction_master_requests_cpu_jtag_debug_module) & (cpu_instruction_master_granted_cpu_jtag_debug_module | ~cpu_instruction_master_qualified_request_cpu_jtag_debug_module) & ((~cpu_instruction_master_qualified_request_cpu_jtag_debug_module | ~cpu_instruction_master_read | (1 & ~d1_cpu_jtag_debug_module_end_xfer & cpu_instruction_master_read))) & 1 & (cpu_instruction_master_qualified_request_onchip_memory_s1 | cpu_instruction_master_read_data_valid_onchip_memory_s1 | ~cpu_instruction_master_requests_onchip_memory_s1) & (cpu_instruction_master_granted_onchip_memory_s1 | ~cpu_instruction_master_qualified_request_onchip_memory_s1) & ((~cpu_instruction_master_qualified_request_onchip_memory_s1 | ~cpu_instruction_master_read | (cpu_instruction_master_read_data_valid_onchip_memory_s1 & cpu_instruction_master_read)));

  //cascaded wait assignment, which is an e_assign
  assign cpu_instruction_master_run = r_0;

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_instruction_master_address_to_slave = cpu_instruction_master_address[18 : 0];

  //cpu/instruction_master readdata mux, which is an e_mux
  assign cpu_instruction_master_readdata = ({32 {~cpu_instruction_master_requests_cpu_jtag_debug_module}} | cpu_jtag_debug_module_readdata_from_sa) &
    ({32 {~cpu_instruction_master_requests_onchip_memory_s1}} | onchip_memory_s1_readdata_from_sa);

  //actual waitrequest port, which is an e_assign
  assign cpu_instruction_master_waitrequest = ~cpu_instruction_master_run;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_instruction_master_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_address_last_time <= 0;
      else 
        cpu_instruction_master_address_last_time <= cpu_instruction_master_address;
    end


  //cpu/instruction_master waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= cpu_instruction_master_waitrequest & (cpu_instruction_master_read);
    end


  //cpu_instruction_master_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_instruction_master_address != cpu_instruction_master_address_last_time))
        begin
          $write("%0d ns: cpu_instruction_master_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_instruction_master_read check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_read_last_time <= 0;
      else 
        cpu_instruction_master_read_last_time <= cpu_instruction_master_read;
    end


  //cpu_instruction_master_read matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_instruction_master_read != cpu_instruction_master_read_last_time))
        begin
          $write("%0d ns: cpu_instruction_master_read did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module jtag_uart_avalon_jtag_slave_arbitrator (
                                                // inputs:
                                                 clk,
                                                 cpu_data_master_address_to_slave,
                                                 cpu_data_master_read,
                                                 cpu_data_master_waitrequest,
                                                 cpu_data_master_write,
                                                 cpu_data_master_writedata,
                                                 jtag_uart_avalon_jtag_slave_dataavailable,
                                                 jtag_uart_avalon_jtag_slave_irq,
                                                 jtag_uart_avalon_jtag_slave_readdata,
                                                 jtag_uart_avalon_jtag_slave_readyfordata,
                                                 jtag_uart_avalon_jtag_slave_waitrequest,
                                                 reset_n,

                                                // outputs:
                                                 cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
                                                 cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
                                                 cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
                                                 cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
                                                 d1_jtag_uart_avalon_jtag_slave_end_xfer,
                                                 jtag_uart_avalon_jtag_slave_address,
                                                 jtag_uart_avalon_jtag_slave_chipselect,
                                                 jtag_uart_avalon_jtag_slave_dataavailable_from_sa,
                                                 jtag_uart_avalon_jtag_slave_irq_from_sa,
                                                 jtag_uart_avalon_jtag_slave_read_n,
                                                 jtag_uart_avalon_jtag_slave_readdata_from_sa,
                                                 jtag_uart_avalon_jtag_slave_readyfordata_from_sa,
                                                 jtag_uart_avalon_jtag_slave_reset_n,
                                                 jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
                                                 jtag_uart_avalon_jtag_slave_write_n,
                                                 jtag_uart_avalon_jtag_slave_writedata
                                              )
;

  output           cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  output           cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  output           cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  output           cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  output           d1_jtag_uart_avalon_jtag_slave_end_xfer;
  output           jtag_uart_avalon_jtag_slave_address;
  output           jtag_uart_avalon_jtag_slave_chipselect;
  output           jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  output           jtag_uart_avalon_jtag_slave_irq_from_sa;
  output           jtag_uart_avalon_jtag_slave_read_n;
  output  [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  output           jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  output           jtag_uart_avalon_jtag_slave_reset_n;
  output           jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  output           jtag_uart_avalon_jtag_slave_write_n;
  output  [ 31: 0] jtag_uart_avalon_jtag_slave_writedata;
  input            clk;
  input   [ 18: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            jtag_uart_avalon_jtag_slave_dataavailable;
  input            jtag_uart_avalon_jtag_slave_irq;
  input   [ 31: 0] jtag_uart_avalon_jtag_slave_readdata;
  input            jtag_uart_avalon_jtag_slave_readyfordata;
  input            jtag_uart_avalon_jtag_slave_waitrequest;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave;
  reg              d1_jtag_uart_avalon_jtag_slave_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire             jtag_uart_avalon_jtag_slave_address;
  wire             jtag_uart_avalon_jtag_slave_allgrants;
  wire             jtag_uart_avalon_jtag_slave_allow_new_arb_cycle;
  wire             jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant;
  wire             jtag_uart_avalon_jtag_slave_any_continuerequest;
  wire             jtag_uart_avalon_jtag_slave_arb_counter_enable;
  reg              jtag_uart_avalon_jtag_slave_arb_share_counter;
  wire             jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
  wire             jtag_uart_avalon_jtag_slave_arb_share_set_values;
  wire             jtag_uart_avalon_jtag_slave_beginbursttransfer_internal;
  wire             jtag_uart_avalon_jtag_slave_begins_xfer;
  wire             jtag_uart_avalon_jtag_slave_chipselect;
  wire             jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_avalon_jtag_slave_end_xfer;
  wire             jtag_uart_avalon_jtag_slave_firsttransfer;
  wire             jtag_uart_avalon_jtag_slave_grant_vector;
  wire             jtag_uart_avalon_jtag_slave_in_a_read_cycle;
  wire             jtag_uart_avalon_jtag_slave_in_a_write_cycle;
  wire             jtag_uart_avalon_jtag_slave_irq_from_sa;
  wire             jtag_uart_avalon_jtag_slave_master_qreq_vector;
  wire             jtag_uart_avalon_jtag_slave_non_bursting_master_requests;
  wire             jtag_uart_avalon_jtag_slave_read_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  wire             jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  reg              jtag_uart_avalon_jtag_slave_reg_firsttransfer;
  wire             jtag_uart_avalon_jtag_slave_reset_n;
  reg              jtag_uart_avalon_jtag_slave_slavearbiterlockenable;
  wire             jtag_uart_avalon_jtag_slave_slavearbiterlockenable2;
  wire             jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
  wire             jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  wire             jtag_uart_avalon_jtag_slave_waits_for_read;
  wire             jtag_uart_avalon_jtag_slave_waits_for_write;
  wire             jtag_uart_avalon_jtag_slave_write_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_writedata;
  wire    [ 18: 0] shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master;
  wire             wait_for_jtag_uart_avalon_jtag_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~jtag_uart_avalon_jtag_slave_end_xfer;
    end


  assign jtag_uart_avalon_jtag_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave));
  //assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata;

  assign cpu_data_master_requests_jtag_uart_avalon_jtag_slave = ({cpu_data_master_address_to_slave[18 : 3] , 3'b0} == 19'h41000) & (cpu_data_master_read | cpu_data_master_write);
  //assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable;

  //assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata;

  //assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest;

  //jtag_uart_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_arb_share_set_values = 1;

  //jtag_uart_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_non_bursting_master_requests = cpu_data_master_requests_jtag_uart_avalon_jtag_slave;

  //jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant = 0;

  //jtag_uart_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_arb_share_counter_next_value = jtag_uart_avalon_jtag_slave_firsttransfer ? (jtag_uart_avalon_jtag_slave_arb_share_set_values - 1) : |jtag_uart_avalon_jtag_slave_arb_share_counter ? (jtag_uart_avalon_jtag_slave_arb_share_counter - 1) : 0;

  //jtag_uart_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_allgrants = |jtag_uart_avalon_jtag_slave_grant_vector;

  //jtag_uart_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_end_xfer = ~(jtag_uart_avalon_jtag_slave_waits_for_read | jtag_uart_avalon_jtag_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave = jtag_uart_avalon_jtag_slave_end_xfer & (~jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //jtag_uart_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave & jtag_uart_avalon_jtag_slave_allgrants) | (end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave & ~jtag_uart_avalon_jtag_slave_non_bursting_master_requests);

  //jtag_uart_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_avalon_jtag_slave_arb_share_counter <= 0;
      else if (jtag_uart_avalon_jtag_slave_arb_counter_enable)
          jtag_uart_avalon_jtag_slave_arb_share_counter <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
    end


  //jtag_uart_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= 0;
      else if ((|jtag_uart_avalon_jtag_slave_master_qreq_vector & end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave) | (end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave & ~jtag_uart_avalon_jtag_slave_non_bursting_master_requests))
          jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= |jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
    end


  //cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = jtag_uart_avalon_jtag_slave_slavearbiterlockenable & cpu_data_master_continuerequest;

  //jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 = |jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;

  //cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //jtag_uart_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave = cpu_data_master_requests_jtag_uart_avalon_jtag_slave & ~((cpu_data_master_read & (~cpu_data_master_waitrequest)) | ((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //jtag_uart_avalon_jtag_slave_writedata mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_jtag_uart_avalon_jtag_slave = cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;

  //cpu/data_master saved-grant jtag_uart/avalon_jtag_slave, which is an e_assign
  assign cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave = cpu_data_master_requests_jtag_uart_avalon_jtag_slave;

  //allow new arb cycle for jtag_uart/avalon_jtag_slave, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign jtag_uart_avalon_jtag_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign jtag_uart_avalon_jtag_slave_master_qreq_vector = 1;

  //jtag_uart_avalon_jtag_slave_reset_n assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_reset_n = reset_n;

  assign jtag_uart_avalon_jtag_slave_chipselect = cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  //jtag_uart_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_firsttransfer = jtag_uart_avalon_jtag_slave_begins_xfer ? jtag_uart_avalon_jtag_slave_unreg_firsttransfer : jtag_uart_avalon_jtag_slave_reg_firsttransfer;

  //jtag_uart_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_unreg_firsttransfer = ~(jtag_uart_avalon_jtag_slave_slavearbiterlockenable & jtag_uart_avalon_jtag_slave_any_continuerequest);

  //jtag_uart_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_avalon_jtag_slave_reg_firsttransfer <= 1'b1;
      else if (jtag_uart_avalon_jtag_slave_begins_xfer)
          jtag_uart_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
    end


  //jtag_uart_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_beginbursttransfer_internal = jtag_uart_avalon_jtag_slave_begins_xfer;

  //~jtag_uart_avalon_jtag_slave_read_n assignment, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_read_n = ~(cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_read);

  //~jtag_uart_avalon_jtag_slave_write_n assignment, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_write_n = ~(cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_write);

  assign shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master = cpu_data_master_address_to_slave;
  //jtag_uart_avalon_jtag_slave_address mux, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_address = shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master >> 2;

  //d1_jtag_uart_avalon_jtag_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_jtag_uart_avalon_jtag_slave_end_xfer <= 1;
      else 
        d1_jtag_uart_avalon_jtag_slave_end_xfer <= jtag_uart_avalon_jtag_slave_end_xfer;
    end


  //jtag_uart_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_waits_for_read = jtag_uart_avalon_jtag_slave_in_a_read_cycle & jtag_uart_avalon_jtag_slave_waitrequest_from_sa;

  //jtag_uart_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_in_a_read_cycle = cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = jtag_uart_avalon_jtag_slave_in_a_read_cycle;

  //jtag_uart_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  assign jtag_uart_avalon_jtag_slave_waits_for_write = jtag_uart_avalon_jtag_slave_in_a_write_cycle & jtag_uart_avalon_jtag_slave_waitrequest_from_sa;

  //jtag_uart_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_in_a_write_cycle = cpu_data_master_granted_jtag_uart_avalon_jtag_slave & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = jtag_uart_avalon_jtag_slave_in_a_write_cycle;

  assign wait_for_jtag_uart_avalon_jtag_slave_counter = 0;
  //assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //jtag_uart/avalon_jtag_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module onchip_memory_s1_arbitrator (
                                     // inputs:
                                      clk,
                                      cpu_data_master_address_to_slave,
                                      cpu_data_master_byteenable,
                                      cpu_data_master_read,
                                      cpu_data_master_waitrequest,
                                      cpu_data_master_write,
                                      cpu_data_master_writedata,
                                      cpu_instruction_master_address_to_slave,
                                      cpu_instruction_master_read,
                                      onchip_memory_s1_readdata,
                                      reset_n,

                                     // outputs:
                                      cpu_data_master_granted_onchip_memory_s1,
                                      cpu_data_master_qualified_request_onchip_memory_s1,
                                      cpu_data_master_read_data_valid_onchip_memory_s1,
                                      cpu_data_master_requests_onchip_memory_s1,
                                      cpu_instruction_master_granted_onchip_memory_s1,
                                      cpu_instruction_master_qualified_request_onchip_memory_s1,
                                      cpu_instruction_master_read_data_valid_onchip_memory_s1,
                                      cpu_instruction_master_requests_onchip_memory_s1,
                                      d1_onchip_memory_s1_end_xfer,
                                      onchip_memory_s1_address,
                                      onchip_memory_s1_byteenable,
                                      onchip_memory_s1_chipselect,
                                      onchip_memory_s1_clken,
                                      onchip_memory_s1_readdata_from_sa,
                                      onchip_memory_s1_write,
                                      onchip_memory_s1_writedata,
                                      registered_cpu_data_master_read_data_valid_onchip_memory_s1
                                   )
;

  output           cpu_data_master_granted_onchip_memory_s1;
  output           cpu_data_master_qualified_request_onchip_memory_s1;
  output           cpu_data_master_read_data_valid_onchip_memory_s1;
  output           cpu_data_master_requests_onchip_memory_s1;
  output           cpu_instruction_master_granted_onchip_memory_s1;
  output           cpu_instruction_master_qualified_request_onchip_memory_s1;
  output           cpu_instruction_master_read_data_valid_onchip_memory_s1;
  output           cpu_instruction_master_requests_onchip_memory_s1;
  output           d1_onchip_memory_s1_end_xfer;
  output  [ 14: 0] onchip_memory_s1_address;
  output  [  3: 0] onchip_memory_s1_byteenable;
  output           onchip_memory_s1_chipselect;
  output           onchip_memory_s1_clken;
  output  [ 31: 0] onchip_memory_s1_readdata_from_sa;
  output           onchip_memory_s1_write;
  output  [ 31: 0] onchip_memory_s1_writedata;
  output           registered_cpu_data_master_read_data_valid_onchip_memory_s1;
  input            clk;
  input   [ 18: 0] cpu_data_master_address_to_slave;
  input   [  3: 0] cpu_data_master_byteenable;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input   [ 18: 0] cpu_instruction_master_address_to_slave;
  input            cpu_instruction_master_read;
  input   [ 31: 0] onchip_memory_s1_readdata;
  input            reset_n;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_onchip_memory_s1;
  wire             cpu_data_master_qualified_request_onchip_memory_s1;
  wire             cpu_data_master_read_data_valid_onchip_memory_s1;
  reg              cpu_data_master_read_data_valid_onchip_memory_s1_shift_register;
  wire             cpu_data_master_read_data_valid_onchip_memory_s1_shift_register_in;
  wire             cpu_data_master_requests_onchip_memory_s1;
  wire             cpu_data_master_saved_grant_onchip_memory_s1;
  wire             cpu_instruction_master_arbiterlock;
  wire             cpu_instruction_master_arbiterlock2;
  wire             cpu_instruction_master_continuerequest;
  wire             cpu_instruction_master_granted_onchip_memory_s1;
  wire             cpu_instruction_master_qualified_request_onchip_memory_s1;
  wire             cpu_instruction_master_read_data_valid_onchip_memory_s1;
  reg              cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register;
  wire             cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register_in;
  wire             cpu_instruction_master_requests_onchip_memory_s1;
  wire             cpu_instruction_master_saved_grant_onchip_memory_s1;
  reg              d1_onchip_memory_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_onchip_memory_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_data_master_granted_slave_onchip_memory_s1;
  reg              last_cycle_cpu_instruction_master_granted_slave_onchip_memory_s1;
  wire    [ 14: 0] onchip_memory_s1_address;
  wire             onchip_memory_s1_allgrants;
  wire             onchip_memory_s1_allow_new_arb_cycle;
  wire             onchip_memory_s1_any_bursting_master_saved_grant;
  wire             onchip_memory_s1_any_continuerequest;
  reg     [  1: 0] onchip_memory_s1_arb_addend;
  wire             onchip_memory_s1_arb_counter_enable;
  reg              onchip_memory_s1_arb_share_counter;
  wire             onchip_memory_s1_arb_share_counter_next_value;
  wire             onchip_memory_s1_arb_share_set_values;
  wire    [  1: 0] onchip_memory_s1_arb_winner;
  wire             onchip_memory_s1_arbitration_holdoff_internal;
  wire             onchip_memory_s1_beginbursttransfer_internal;
  wire             onchip_memory_s1_begins_xfer;
  wire    [  3: 0] onchip_memory_s1_byteenable;
  wire             onchip_memory_s1_chipselect;
  wire    [  3: 0] onchip_memory_s1_chosen_master_double_vector;
  wire    [  1: 0] onchip_memory_s1_chosen_master_rot_left;
  wire             onchip_memory_s1_clken;
  wire             onchip_memory_s1_end_xfer;
  wire             onchip_memory_s1_firsttransfer;
  wire    [  1: 0] onchip_memory_s1_grant_vector;
  wire             onchip_memory_s1_in_a_read_cycle;
  wire             onchip_memory_s1_in_a_write_cycle;
  wire    [  1: 0] onchip_memory_s1_master_qreq_vector;
  wire             onchip_memory_s1_non_bursting_master_requests;
  wire    [ 31: 0] onchip_memory_s1_readdata_from_sa;
  reg              onchip_memory_s1_reg_firsttransfer;
  reg     [  1: 0] onchip_memory_s1_saved_chosen_master_vector;
  reg              onchip_memory_s1_slavearbiterlockenable;
  wire             onchip_memory_s1_slavearbiterlockenable2;
  wire             onchip_memory_s1_unreg_firsttransfer;
  wire             onchip_memory_s1_waits_for_read;
  wire             onchip_memory_s1_waits_for_write;
  wire             onchip_memory_s1_write;
  wire    [ 31: 0] onchip_memory_s1_writedata;
  wire             p1_cpu_data_master_read_data_valid_onchip_memory_s1_shift_register;
  wire             p1_cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register;
  wire             registered_cpu_data_master_read_data_valid_onchip_memory_s1;
  wire    [ 18: 0] shifted_address_to_onchip_memory_s1_from_cpu_data_master;
  wire    [ 18: 0] shifted_address_to_onchip_memory_s1_from_cpu_instruction_master;
  wire             wait_for_onchip_memory_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~onchip_memory_s1_end_xfer;
    end


  assign onchip_memory_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_onchip_memory_s1 | cpu_instruction_master_qualified_request_onchip_memory_s1));
  //assign onchip_memory_s1_readdata_from_sa = onchip_memory_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign onchip_memory_s1_readdata_from_sa = onchip_memory_s1_readdata;

  assign cpu_data_master_requests_onchip_memory_s1 = ({cpu_data_master_address_to_slave[18 : 17] , 17'b0} == 19'h20000) & (cpu_data_master_read | cpu_data_master_write);
  //registered rdv signal_name registered_cpu_data_master_read_data_valid_onchip_memory_s1 assignment, which is an e_assign
  assign registered_cpu_data_master_read_data_valid_onchip_memory_s1 = cpu_data_master_read_data_valid_onchip_memory_s1_shift_register_in;

  //onchip_memory_s1_arb_share_counter set values, which is an e_mux
  assign onchip_memory_s1_arb_share_set_values = 1;

  //onchip_memory_s1_non_bursting_master_requests mux, which is an e_mux
  assign onchip_memory_s1_non_bursting_master_requests = cpu_data_master_requests_onchip_memory_s1 |
    cpu_instruction_master_requests_onchip_memory_s1 |
    cpu_data_master_requests_onchip_memory_s1 |
    cpu_instruction_master_requests_onchip_memory_s1;

  //onchip_memory_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign onchip_memory_s1_any_bursting_master_saved_grant = 0;

  //onchip_memory_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign onchip_memory_s1_arb_share_counter_next_value = onchip_memory_s1_firsttransfer ? (onchip_memory_s1_arb_share_set_values - 1) : |onchip_memory_s1_arb_share_counter ? (onchip_memory_s1_arb_share_counter - 1) : 0;

  //onchip_memory_s1_allgrants all slave grants, which is an e_mux
  assign onchip_memory_s1_allgrants = (|onchip_memory_s1_grant_vector) |
    (|onchip_memory_s1_grant_vector) |
    (|onchip_memory_s1_grant_vector) |
    (|onchip_memory_s1_grant_vector);

  //onchip_memory_s1_end_xfer assignment, which is an e_assign
  assign onchip_memory_s1_end_xfer = ~(onchip_memory_s1_waits_for_read | onchip_memory_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_onchip_memory_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_onchip_memory_s1 = onchip_memory_s1_end_xfer & (~onchip_memory_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //onchip_memory_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign onchip_memory_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_onchip_memory_s1 & onchip_memory_s1_allgrants) | (end_xfer_arb_share_counter_term_onchip_memory_s1 & ~onchip_memory_s1_non_bursting_master_requests);

  //onchip_memory_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_s1_arb_share_counter <= 0;
      else if (onchip_memory_s1_arb_counter_enable)
          onchip_memory_s1_arb_share_counter <= onchip_memory_s1_arb_share_counter_next_value;
    end


  //onchip_memory_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_s1_slavearbiterlockenable <= 0;
      else if ((|onchip_memory_s1_master_qreq_vector & end_xfer_arb_share_counter_term_onchip_memory_s1) | (end_xfer_arb_share_counter_term_onchip_memory_s1 & ~onchip_memory_s1_non_bursting_master_requests))
          onchip_memory_s1_slavearbiterlockenable <= |onchip_memory_s1_arb_share_counter_next_value;
    end


  //cpu/data_master onchip_memory/s1 arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = onchip_memory_s1_slavearbiterlockenable & cpu_data_master_continuerequest;

  //onchip_memory_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign onchip_memory_s1_slavearbiterlockenable2 = |onchip_memory_s1_arb_share_counter_next_value;

  //cpu/data_master onchip_memory/s1 arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = onchip_memory_s1_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //cpu/instruction_master onchip_memory/s1 arbiterlock, which is an e_assign
  assign cpu_instruction_master_arbiterlock = onchip_memory_s1_slavearbiterlockenable & cpu_instruction_master_continuerequest;

  //cpu/instruction_master onchip_memory/s1 arbiterlock2, which is an e_assign
  assign cpu_instruction_master_arbiterlock2 = onchip_memory_s1_slavearbiterlockenable2 & cpu_instruction_master_continuerequest;

  //cpu/instruction_master granted onchip_memory/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_instruction_master_granted_slave_onchip_memory_s1 <= 0;
      else 
        last_cycle_cpu_instruction_master_granted_slave_onchip_memory_s1 <= cpu_instruction_master_saved_grant_onchip_memory_s1 ? 1 : (onchip_memory_s1_arbitration_holdoff_internal | ~cpu_instruction_master_requests_onchip_memory_s1) ? 0 : last_cycle_cpu_instruction_master_granted_slave_onchip_memory_s1;
    end


  //cpu_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_instruction_master_continuerequest = last_cycle_cpu_instruction_master_granted_slave_onchip_memory_s1 & cpu_instruction_master_requests_onchip_memory_s1;

  //onchip_memory_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  assign onchip_memory_s1_any_continuerequest = cpu_instruction_master_continuerequest |
    cpu_data_master_continuerequest;

  assign cpu_data_master_qualified_request_onchip_memory_s1 = cpu_data_master_requests_onchip_memory_s1 & ~((cpu_data_master_read & ((|cpu_data_master_read_data_valid_onchip_memory_s1_shift_register))) | ((~cpu_data_master_waitrequest) & cpu_data_master_write) | cpu_instruction_master_arbiterlock);
  //cpu_data_master_read_data_valid_onchip_memory_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  assign cpu_data_master_read_data_valid_onchip_memory_s1_shift_register_in = cpu_data_master_granted_onchip_memory_s1 & cpu_data_master_read & ~onchip_memory_s1_waits_for_read & ~(|cpu_data_master_read_data_valid_onchip_memory_s1_shift_register);

  //shift register p1 cpu_data_master_read_data_valid_onchip_memory_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  assign p1_cpu_data_master_read_data_valid_onchip_memory_s1_shift_register = {cpu_data_master_read_data_valid_onchip_memory_s1_shift_register, cpu_data_master_read_data_valid_onchip_memory_s1_shift_register_in};

  //cpu_data_master_read_data_valid_onchip_memory_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_data_master_read_data_valid_onchip_memory_s1_shift_register <= 0;
      else 
        cpu_data_master_read_data_valid_onchip_memory_s1_shift_register <= p1_cpu_data_master_read_data_valid_onchip_memory_s1_shift_register;
    end


  //local readdatavalid cpu_data_master_read_data_valid_onchip_memory_s1, which is an e_mux
  assign cpu_data_master_read_data_valid_onchip_memory_s1 = cpu_data_master_read_data_valid_onchip_memory_s1_shift_register;

  //onchip_memory_s1_writedata mux, which is an e_mux
  assign onchip_memory_s1_writedata = cpu_data_master_writedata;

  //mux onchip_memory_s1_clken, which is an e_mux
  assign onchip_memory_s1_clken = 1'b1;

  assign cpu_instruction_master_requests_onchip_memory_s1 = (({cpu_instruction_master_address_to_slave[18 : 17] , 17'b0} == 19'h20000) & (cpu_instruction_master_read)) & cpu_instruction_master_read;
  //cpu/data_master granted onchip_memory/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_data_master_granted_slave_onchip_memory_s1 <= 0;
      else 
        last_cycle_cpu_data_master_granted_slave_onchip_memory_s1 <= cpu_data_master_saved_grant_onchip_memory_s1 ? 1 : (onchip_memory_s1_arbitration_holdoff_internal | ~cpu_data_master_requests_onchip_memory_s1) ? 0 : last_cycle_cpu_data_master_granted_slave_onchip_memory_s1;
    end


  //cpu_data_master_continuerequest continued request, which is an e_mux
  assign cpu_data_master_continuerequest = last_cycle_cpu_data_master_granted_slave_onchip_memory_s1 & cpu_data_master_requests_onchip_memory_s1;

  assign cpu_instruction_master_qualified_request_onchip_memory_s1 = cpu_instruction_master_requests_onchip_memory_s1 & ~((cpu_instruction_master_read & ((|cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register))) | cpu_data_master_arbiterlock);
  //cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  assign cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register_in = cpu_instruction_master_granted_onchip_memory_s1 & cpu_instruction_master_read & ~onchip_memory_s1_waits_for_read & ~(|cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register);

  //shift register p1 cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  assign p1_cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register = {cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register, cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register_in};

  //cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register <= 0;
      else 
        cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register <= p1_cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register;
    end


  //local readdatavalid cpu_instruction_master_read_data_valid_onchip_memory_s1, which is an e_mux
  assign cpu_instruction_master_read_data_valid_onchip_memory_s1 = cpu_instruction_master_read_data_valid_onchip_memory_s1_shift_register;

  //allow new arb cycle for onchip_memory/s1, which is an e_assign
  assign onchip_memory_s1_allow_new_arb_cycle = ~cpu_data_master_arbiterlock & ~cpu_instruction_master_arbiterlock;

  //cpu/instruction_master assignment into master qualified-requests vector for onchip_memory/s1, which is an e_assign
  assign onchip_memory_s1_master_qreq_vector[0] = cpu_instruction_master_qualified_request_onchip_memory_s1;

  //cpu/instruction_master grant onchip_memory/s1, which is an e_assign
  assign cpu_instruction_master_granted_onchip_memory_s1 = onchip_memory_s1_grant_vector[0];

  //cpu/instruction_master saved-grant onchip_memory/s1, which is an e_assign
  assign cpu_instruction_master_saved_grant_onchip_memory_s1 = onchip_memory_s1_arb_winner[0] && cpu_instruction_master_requests_onchip_memory_s1;

  //cpu/data_master assignment into master qualified-requests vector for onchip_memory/s1, which is an e_assign
  assign onchip_memory_s1_master_qreq_vector[1] = cpu_data_master_qualified_request_onchip_memory_s1;

  //cpu/data_master grant onchip_memory/s1, which is an e_assign
  assign cpu_data_master_granted_onchip_memory_s1 = onchip_memory_s1_grant_vector[1];

  //cpu/data_master saved-grant onchip_memory/s1, which is an e_assign
  assign cpu_data_master_saved_grant_onchip_memory_s1 = onchip_memory_s1_arb_winner[1] && cpu_data_master_requests_onchip_memory_s1;

  //onchip_memory/s1 chosen-master double-vector, which is an e_assign
  assign onchip_memory_s1_chosen_master_double_vector = {onchip_memory_s1_master_qreq_vector, onchip_memory_s1_master_qreq_vector} & ({~onchip_memory_s1_master_qreq_vector, ~onchip_memory_s1_master_qreq_vector} + onchip_memory_s1_arb_addend);

  //stable onehot encoding of arb winner
  assign onchip_memory_s1_arb_winner = (onchip_memory_s1_allow_new_arb_cycle & | onchip_memory_s1_grant_vector) ? onchip_memory_s1_grant_vector : onchip_memory_s1_saved_chosen_master_vector;

  //saved onchip_memory_s1_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_s1_saved_chosen_master_vector <= 0;
      else if (onchip_memory_s1_allow_new_arb_cycle)
          onchip_memory_s1_saved_chosen_master_vector <= |onchip_memory_s1_grant_vector ? onchip_memory_s1_grant_vector : onchip_memory_s1_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign onchip_memory_s1_grant_vector = {(onchip_memory_s1_chosen_master_double_vector[1] | onchip_memory_s1_chosen_master_double_vector[3]),
    (onchip_memory_s1_chosen_master_double_vector[0] | onchip_memory_s1_chosen_master_double_vector[2])};

  //onchip_memory/s1 chosen master rotated left, which is an e_assign
  assign onchip_memory_s1_chosen_master_rot_left = (onchip_memory_s1_arb_winner << 1) ? (onchip_memory_s1_arb_winner << 1) : 1;

  //onchip_memory/s1's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_s1_arb_addend <= 1;
      else if (|onchip_memory_s1_grant_vector)
          onchip_memory_s1_arb_addend <= onchip_memory_s1_end_xfer? onchip_memory_s1_chosen_master_rot_left : onchip_memory_s1_grant_vector;
    end


  assign onchip_memory_s1_chipselect = cpu_data_master_granted_onchip_memory_s1 | cpu_instruction_master_granted_onchip_memory_s1;
  //onchip_memory_s1_firsttransfer first transaction, which is an e_assign
  assign onchip_memory_s1_firsttransfer = onchip_memory_s1_begins_xfer ? onchip_memory_s1_unreg_firsttransfer : onchip_memory_s1_reg_firsttransfer;

  //onchip_memory_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign onchip_memory_s1_unreg_firsttransfer = ~(onchip_memory_s1_slavearbiterlockenable & onchip_memory_s1_any_continuerequest);

  //onchip_memory_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_s1_reg_firsttransfer <= 1'b1;
      else if (onchip_memory_s1_begins_xfer)
          onchip_memory_s1_reg_firsttransfer <= onchip_memory_s1_unreg_firsttransfer;
    end


  //onchip_memory_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign onchip_memory_s1_beginbursttransfer_internal = onchip_memory_s1_begins_xfer;

  //onchip_memory_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign onchip_memory_s1_arbitration_holdoff_internal = onchip_memory_s1_begins_xfer & onchip_memory_s1_firsttransfer;

  //onchip_memory_s1_write assignment, which is an e_mux
  assign onchip_memory_s1_write = cpu_data_master_granted_onchip_memory_s1 & cpu_data_master_write;

  assign shifted_address_to_onchip_memory_s1_from_cpu_data_master = cpu_data_master_address_to_slave;
  //onchip_memory_s1_address mux, which is an e_mux
  assign onchip_memory_s1_address = (cpu_data_master_granted_onchip_memory_s1)? (shifted_address_to_onchip_memory_s1_from_cpu_data_master >> 2) :
    (shifted_address_to_onchip_memory_s1_from_cpu_instruction_master >> 2);

  assign shifted_address_to_onchip_memory_s1_from_cpu_instruction_master = cpu_instruction_master_address_to_slave;
  //d1_onchip_memory_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_onchip_memory_s1_end_xfer <= 1;
      else 
        d1_onchip_memory_s1_end_xfer <= onchip_memory_s1_end_xfer;
    end


  //onchip_memory_s1_waits_for_read in a cycle, which is an e_mux
  assign onchip_memory_s1_waits_for_read = onchip_memory_s1_in_a_read_cycle & 0;

  //onchip_memory_s1_in_a_read_cycle assignment, which is an e_assign
  assign onchip_memory_s1_in_a_read_cycle = (cpu_data_master_granted_onchip_memory_s1 & cpu_data_master_read) | (cpu_instruction_master_granted_onchip_memory_s1 & cpu_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = onchip_memory_s1_in_a_read_cycle;

  //onchip_memory_s1_waits_for_write in a cycle, which is an e_mux
  assign onchip_memory_s1_waits_for_write = onchip_memory_s1_in_a_write_cycle & 0;

  //onchip_memory_s1_in_a_write_cycle assignment, which is an e_assign
  assign onchip_memory_s1_in_a_write_cycle = cpu_data_master_granted_onchip_memory_s1 & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = onchip_memory_s1_in_a_write_cycle;

  assign wait_for_onchip_memory_s1_counter = 0;
  //onchip_memory_s1_byteenable byte enable port mux, which is an e_mux
  assign onchip_memory_s1_byteenable = (cpu_data_master_granted_onchip_memory_s1)? cpu_data_master_byteenable :
    -1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //onchip_memory/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_granted_onchip_memory_s1 + cpu_instruction_master_granted_onchip_memory_s1 > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_data_master_saved_grant_onchip_memory_s1 + cpu_instruction_master_saved_grant_onchip_memory_s1 > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module stopwatch_i_avalon_slave_arbitrator (
                                             // inputs:
                                              clk,
                                              cpu_data_master_address_to_slave,
                                              cpu_data_master_read,
                                              cpu_data_master_waitrequest,
                                              cpu_data_master_write,
                                              cpu_data_master_writedata,
                                              reset_n,
                                              stopwatch_i_avalon_slave_irq,
                                              stopwatch_i_avalon_slave_readdata,

                                             // outputs:
                                              cpu_data_master_granted_stopwatch_i_avalon_slave,
                                              cpu_data_master_qualified_request_stopwatch_i_avalon_slave,
                                              cpu_data_master_read_data_valid_stopwatch_i_avalon_slave,
                                              cpu_data_master_requests_stopwatch_i_avalon_slave,
                                              d1_stopwatch_i_avalon_slave_end_xfer,
                                              stopwatch_i_avalon_slave_irq_from_sa,
                                              stopwatch_i_avalon_slave_read,
                                              stopwatch_i_avalon_slave_readdata_from_sa,
                                              stopwatch_i_avalon_slave_reset,
                                              stopwatch_i_avalon_slave_write,
                                              stopwatch_i_avalon_slave_writedata
                                           )
;

  output           cpu_data_master_granted_stopwatch_i_avalon_slave;
  output           cpu_data_master_qualified_request_stopwatch_i_avalon_slave;
  output           cpu_data_master_read_data_valid_stopwatch_i_avalon_slave;
  output           cpu_data_master_requests_stopwatch_i_avalon_slave;
  output           d1_stopwatch_i_avalon_slave_end_xfer;
  output           stopwatch_i_avalon_slave_irq_from_sa;
  output           stopwatch_i_avalon_slave_read;
  output  [ 31: 0] stopwatch_i_avalon_slave_readdata_from_sa;
  output           stopwatch_i_avalon_slave_reset;
  output           stopwatch_i_avalon_slave_write;
  output  [ 31: 0] stopwatch_i_avalon_slave_writedata;
  input            clk;
  input   [ 18: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;
  input            stopwatch_i_avalon_slave_irq;
  input   [ 31: 0] stopwatch_i_avalon_slave_readdata;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_stopwatch_i_avalon_slave;
  wire             cpu_data_master_qualified_request_stopwatch_i_avalon_slave;
  wire             cpu_data_master_read_data_valid_stopwatch_i_avalon_slave;
  wire             cpu_data_master_requests_stopwatch_i_avalon_slave;
  wire             cpu_data_master_saved_grant_stopwatch_i_avalon_slave;
  reg              d1_reasons_to_wait;
  reg              d1_stopwatch_i_avalon_slave_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 18: 0] shifted_address_to_stopwatch_i_avalon_slave_from_cpu_data_master;
  wire             stopwatch_i_avalon_slave_allgrants;
  wire             stopwatch_i_avalon_slave_allow_new_arb_cycle;
  wire             stopwatch_i_avalon_slave_any_bursting_master_saved_grant;
  wire             stopwatch_i_avalon_slave_any_continuerequest;
  wire             stopwatch_i_avalon_slave_arb_counter_enable;
  reg              stopwatch_i_avalon_slave_arb_share_counter;
  wire             stopwatch_i_avalon_slave_arb_share_counter_next_value;
  wire             stopwatch_i_avalon_slave_arb_share_set_values;
  wire             stopwatch_i_avalon_slave_beginbursttransfer_internal;
  wire             stopwatch_i_avalon_slave_begins_xfer;
  wire             stopwatch_i_avalon_slave_end_xfer;
  wire             stopwatch_i_avalon_slave_firsttransfer;
  wire             stopwatch_i_avalon_slave_grant_vector;
  wire             stopwatch_i_avalon_slave_in_a_read_cycle;
  wire             stopwatch_i_avalon_slave_in_a_write_cycle;
  wire             stopwatch_i_avalon_slave_irq_from_sa;
  wire             stopwatch_i_avalon_slave_master_qreq_vector;
  wire             stopwatch_i_avalon_slave_non_bursting_master_requests;
  wire             stopwatch_i_avalon_slave_read;
  wire    [ 31: 0] stopwatch_i_avalon_slave_readdata_from_sa;
  reg              stopwatch_i_avalon_slave_reg_firsttransfer;
  wire             stopwatch_i_avalon_slave_reset;
  reg              stopwatch_i_avalon_slave_slavearbiterlockenable;
  wire             stopwatch_i_avalon_slave_slavearbiterlockenable2;
  wire             stopwatch_i_avalon_slave_unreg_firsttransfer;
  wire             stopwatch_i_avalon_slave_waits_for_read;
  wire             stopwatch_i_avalon_slave_waits_for_write;
  wire             stopwatch_i_avalon_slave_write;
  wire    [ 31: 0] stopwatch_i_avalon_slave_writedata;
  wire             wait_for_stopwatch_i_avalon_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~stopwatch_i_avalon_slave_end_xfer;
    end


  assign stopwatch_i_avalon_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_stopwatch_i_avalon_slave));
  //assign stopwatch_i_avalon_slave_readdata_from_sa = stopwatch_i_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign stopwatch_i_avalon_slave_readdata_from_sa = stopwatch_i_avalon_slave_readdata;

  assign cpu_data_master_requests_stopwatch_i_avalon_slave = ({cpu_data_master_address_to_slave[18 : 2] , 2'b0} == 19'h41008) & (cpu_data_master_read | cpu_data_master_write);
  //stopwatch_i_avalon_slave_arb_share_counter set values, which is an e_mux
  assign stopwatch_i_avalon_slave_arb_share_set_values = 1;

  //stopwatch_i_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  assign stopwatch_i_avalon_slave_non_bursting_master_requests = cpu_data_master_requests_stopwatch_i_avalon_slave;

  //stopwatch_i_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign stopwatch_i_avalon_slave_any_bursting_master_saved_grant = 0;

  //stopwatch_i_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign stopwatch_i_avalon_slave_arb_share_counter_next_value = stopwatch_i_avalon_slave_firsttransfer ? (stopwatch_i_avalon_slave_arb_share_set_values - 1) : |stopwatch_i_avalon_slave_arb_share_counter ? (stopwatch_i_avalon_slave_arb_share_counter - 1) : 0;

  //stopwatch_i_avalon_slave_allgrants all slave grants, which is an e_mux
  assign stopwatch_i_avalon_slave_allgrants = |stopwatch_i_avalon_slave_grant_vector;

  //stopwatch_i_avalon_slave_end_xfer assignment, which is an e_assign
  assign stopwatch_i_avalon_slave_end_xfer = ~(stopwatch_i_avalon_slave_waits_for_read | stopwatch_i_avalon_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave = stopwatch_i_avalon_slave_end_xfer & (~stopwatch_i_avalon_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //stopwatch_i_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign stopwatch_i_avalon_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave & stopwatch_i_avalon_slave_allgrants) | (end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave & ~stopwatch_i_avalon_slave_non_bursting_master_requests);

  //stopwatch_i_avalon_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stopwatch_i_avalon_slave_arb_share_counter <= 0;
      else if (stopwatch_i_avalon_slave_arb_counter_enable)
          stopwatch_i_avalon_slave_arb_share_counter <= stopwatch_i_avalon_slave_arb_share_counter_next_value;
    end


  //stopwatch_i_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stopwatch_i_avalon_slave_slavearbiterlockenable <= 0;
      else if ((|stopwatch_i_avalon_slave_master_qreq_vector & end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave) | (end_xfer_arb_share_counter_term_stopwatch_i_avalon_slave & ~stopwatch_i_avalon_slave_non_bursting_master_requests))
          stopwatch_i_avalon_slave_slavearbiterlockenable <= |stopwatch_i_avalon_slave_arb_share_counter_next_value;
    end


  //cpu/data_master stopwatch_i/avalon_slave arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = stopwatch_i_avalon_slave_slavearbiterlockenable & cpu_data_master_continuerequest;

  //stopwatch_i_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign stopwatch_i_avalon_slave_slavearbiterlockenable2 = |stopwatch_i_avalon_slave_arb_share_counter_next_value;

  //cpu/data_master stopwatch_i/avalon_slave arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = stopwatch_i_avalon_slave_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //stopwatch_i_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign stopwatch_i_avalon_slave_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_stopwatch_i_avalon_slave = cpu_data_master_requests_stopwatch_i_avalon_slave & ~((cpu_data_master_read & (~cpu_data_master_waitrequest)) | ((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //stopwatch_i_avalon_slave_writedata mux, which is an e_mux
  assign stopwatch_i_avalon_slave_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_stopwatch_i_avalon_slave = cpu_data_master_qualified_request_stopwatch_i_avalon_slave;

  //cpu/data_master saved-grant stopwatch_i/avalon_slave, which is an e_assign
  assign cpu_data_master_saved_grant_stopwatch_i_avalon_slave = cpu_data_master_requests_stopwatch_i_avalon_slave;

  //allow new arb cycle for stopwatch_i/avalon_slave, which is an e_assign
  assign stopwatch_i_avalon_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign stopwatch_i_avalon_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign stopwatch_i_avalon_slave_master_qreq_vector = 1;

  //~stopwatch_i_avalon_slave_reset assignment, which is an e_assign
  assign stopwatch_i_avalon_slave_reset = ~reset_n;

  //stopwatch_i_avalon_slave_firsttransfer first transaction, which is an e_assign
  assign stopwatch_i_avalon_slave_firsttransfer = stopwatch_i_avalon_slave_begins_xfer ? stopwatch_i_avalon_slave_unreg_firsttransfer : stopwatch_i_avalon_slave_reg_firsttransfer;

  //stopwatch_i_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign stopwatch_i_avalon_slave_unreg_firsttransfer = ~(stopwatch_i_avalon_slave_slavearbiterlockenable & stopwatch_i_avalon_slave_any_continuerequest);

  //stopwatch_i_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stopwatch_i_avalon_slave_reg_firsttransfer <= 1'b1;
      else if (stopwatch_i_avalon_slave_begins_xfer)
          stopwatch_i_avalon_slave_reg_firsttransfer <= stopwatch_i_avalon_slave_unreg_firsttransfer;
    end


  //stopwatch_i_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign stopwatch_i_avalon_slave_beginbursttransfer_internal = stopwatch_i_avalon_slave_begins_xfer;

  //stopwatch_i_avalon_slave_read assignment, which is an e_mux
  assign stopwatch_i_avalon_slave_read = cpu_data_master_granted_stopwatch_i_avalon_slave & cpu_data_master_read;

  //stopwatch_i_avalon_slave_write assignment, which is an e_mux
  assign stopwatch_i_avalon_slave_write = cpu_data_master_granted_stopwatch_i_avalon_slave & cpu_data_master_write;

  assign shifted_address_to_stopwatch_i_avalon_slave_from_cpu_data_master = cpu_data_master_address_to_slave;
  //d1_stopwatch_i_avalon_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_stopwatch_i_avalon_slave_end_xfer <= 1;
      else 
        d1_stopwatch_i_avalon_slave_end_xfer <= stopwatch_i_avalon_slave_end_xfer;
    end


  //stopwatch_i_avalon_slave_waits_for_read in a cycle, which is an e_mux
  assign stopwatch_i_avalon_slave_waits_for_read = stopwatch_i_avalon_slave_in_a_read_cycle & 0;

  //stopwatch_i_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  assign stopwatch_i_avalon_slave_in_a_read_cycle = cpu_data_master_granted_stopwatch_i_avalon_slave & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = stopwatch_i_avalon_slave_in_a_read_cycle;

  //stopwatch_i_avalon_slave_waits_for_write in a cycle, which is an e_mux
  assign stopwatch_i_avalon_slave_waits_for_write = stopwatch_i_avalon_slave_in_a_write_cycle & 0;

  //stopwatch_i_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  assign stopwatch_i_avalon_slave_in_a_write_cycle = cpu_data_master_granted_stopwatch_i_avalon_slave & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = stopwatch_i_avalon_slave_in_a_write_cycle;

  assign wait_for_stopwatch_i_avalon_slave_counter = 0;
  //assign stopwatch_i_avalon_slave_irq_from_sa = stopwatch_i_avalon_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign stopwatch_i_avalon_slave_irq_from_sa = stopwatch_i_avalon_slave_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //stopwatch_i/avalon_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module uart_i_avalon_slave_arbitrator (
                                        // inputs:
                                         clk,
                                         cpu_data_master_address_to_slave,
                                         cpu_data_master_read,
                                         cpu_data_master_waitrequest,
                                         cpu_data_master_write,
                                         cpu_data_master_writedata,
                                         reset_n,
                                         uart_i_avalon_slave_irq,
                                         uart_i_avalon_slave_readdata,
                                         uart_i_avalon_slave_waitrequest,

                                        // outputs:
                                         cpu_data_master_granted_uart_i_avalon_slave,
                                         cpu_data_master_qualified_request_uart_i_avalon_slave,
                                         cpu_data_master_read_data_valid_uart_i_avalon_slave,
                                         cpu_data_master_requests_uart_i_avalon_slave,
                                         d1_uart_i_avalon_slave_end_xfer,
                                         uart_i_avalon_slave_irq_from_sa,
                                         uart_i_avalon_slave_read,
                                         uart_i_avalon_slave_readdata_from_sa,
                                         uart_i_avalon_slave_reset,
                                         uart_i_avalon_slave_waitrequest_from_sa,
                                         uart_i_avalon_slave_write,
                                         uart_i_avalon_slave_writedata
                                      )
;

  output           cpu_data_master_granted_uart_i_avalon_slave;
  output           cpu_data_master_qualified_request_uart_i_avalon_slave;
  output           cpu_data_master_read_data_valid_uart_i_avalon_slave;
  output           cpu_data_master_requests_uart_i_avalon_slave;
  output           d1_uart_i_avalon_slave_end_xfer;
  output           uart_i_avalon_slave_irq_from_sa;
  output           uart_i_avalon_slave_read;
  output  [ 31: 0] uart_i_avalon_slave_readdata_from_sa;
  output           uart_i_avalon_slave_reset;
  output           uart_i_avalon_slave_waitrequest_from_sa;
  output           uart_i_avalon_slave_write;
  output  [ 31: 0] uart_i_avalon_slave_writedata;
  input            clk;
  input   [ 18: 0] cpu_data_master_address_to_slave;
  input            cpu_data_master_read;
  input            cpu_data_master_waitrequest;
  input            cpu_data_master_write;
  input   [ 31: 0] cpu_data_master_writedata;
  input            reset_n;
  input            uart_i_avalon_slave_irq;
  input   [ 31: 0] uart_i_avalon_slave_readdata;
  input            uart_i_avalon_slave_waitrequest;

  wire             cpu_data_master_arbiterlock;
  wire             cpu_data_master_arbiterlock2;
  wire             cpu_data_master_continuerequest;
  wire             cpu_data_master_granted_uart_i_avalon_slave;
  wire             cpu_data_master_qualified_request_uart_i_avalon_slave;
  wire             cpu_data_master_read_data_valid_uart_i_avalon_slave;
  wire             cpu_data_master_requests_uart_i_avalon_slave;
  wire             cpu_data_master_saved_grant_uart_i_avalon_slave;
  reg              d1_reasons_to_wait;
  reg              d1_uart_i_avalon_slave_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_uart_i_avalon_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 18: 0] shifted_address_to_uart_i_avalon_slave_from_cpu_data_master;
  wire             uart_i_avalon_slave_allgrants;
  wire             uart_i_avalon_slave_allow_new_arb_cycle;
  wire             uart_i_avalon_slave_any_bursting_master_saved_grant;
  wire             uart_i_avalon_slave_any_continuerequest;
  wire             uart_i_avalon_slave_arb_counter_enable;
  reg              uart_i_avalon_slave_arb_share_counter;
  wire             uart_i_avalon_slave_arb_share_counter_next_value;
  wire             uart_i_avalon_slave_arb_share_set_values;
  wire             uart_i_avalon_slave_beginbursttransfer_internal;
  wire             uart_i_avalon_slave_begins_xfer;
  wire             uart_i_avalon_slave_end_xfer;
  wire             uart_i_avalon_slave_firsttransfer;
  wire             uart_i_avalon_slave_grant_vector;
  wire             uart_i_avalon_slave_in_a_read_cycle;
  wire             uart_i_avalon_slave_in_a_write_cycle;
  wire             uart_i_avalon_slave_irq_from_sa;
  wire             uart_i_avalon_slave_master_qreq_vector;
  wire             uart_i_avalon_slave_non_bursting_master_requests;
  wire             uart_i_avalon_slave_read;
  wire    [ 31: 0] uart_i_avalon_slave_readdata_from_sa;
  reg              uart_i_avalon_slave_reg_firsttransfer;
  wire             uart_i_avalon_slave_reset;
  reg              uart_i_avalon_slave_slavearbiterlockenable;
  wire             uart_i_avalon_slave_slavearbiterlockenable2;
  wire             uart_i_avalon_slave_unreg_firsttransfer;
  wire             uart_i_avalon_slave_waitrequest_from_sa;
  wire             uart_i_avalon_slave_waits_for_read;
  wire             uart_i_avalon_slave_waits_for_write;
  wire             uart_i_avalon_slave_write;
  wire    [ 31: 0] uart_i_avalon_slave_writedata;
  wire             wait_for_uart_i_avalon_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~uart_i_avalon_slave_end_xfer;
    end


  assign uart_i_avalon_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_data_master_qualified_request_uart_i_avalon_slave));
  //assign uart_i_avalon_slave_readdata_from_sa = uart_i_avalon_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_i_avalon_slave_readdata_from_sa = uart_i_avalon_slave_readdata;

  assign cpu_data_master_requests_uart_i_avalon_slave = ({cpu_data_master_address_to_slave[18 : 2] , 2'b0} == 19'h4100c) & (cpu_data_master_read | cpu_data_master_write);
  //assign uart_i_avalon_slave_waitrequest_from_sa = uart_i_avalon_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_i_avalon_slave_waitrequest_from_sa = uart_i_avalon_slave_waitrequest;

  //uart_i_avalon_slave_arb_share_counter set values, which is an e_mux
  assign uart_i_avalon_slave_arb_share_set_values = 1;

  //uart_i_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  assign uart_i_avalon_slave_non_bursting_master_requests = cpu_data_master_requests_uart_i_avalon_slave;

  //uart_i_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign uart_i_avalon_slave_any_bursting_master_saved_grant = 0;

  //uart_i_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign uart_i_avalon_slave_arb_share_counter_next_value = uart_i_avalon_slave_firsttransfer ? (uart_i_avalon_slave_arb_share_set_values - 1) : |uart_i_avalon_slave_arb_share_counter ? (uart_i_avalon_slave_arb_share_counter - 1) : 0;

  //uart_i_avalon_slave_allgrants all slave grants, which is an e_mux
  assign uart_i_avalon_slave_allgrants = |uart_i_avalon_slave_grant_vector;

  //uart_i_avalon_slave_end_xfer assignment, which is an e_assign
  assign uart_i_avalon_slave_end_xfer = ~(uart_i_avalon_slave_waits_for_read | uart_i_avalon_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_uart_i_avalon_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_uart_i_avalon_slave = uart_i_avalon_slave_end_xfer & (~uart_i_avalon_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //uart_i_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign uart_i_avalon_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_uart_i_avalon_slave & uart_i_avalon_slave_allgrants) | (end_xfer_arb_share_counter_term_uart_i_avalon_slave & ~uart_i_avalon_slave_non_bursting_master_requests);

  //uart_i_avalon_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_i_avalon_slave_arb_share_counter <= 0;
      else if (uart_i_avalon_slave_arb_counter_enable)
          uart_i_avalon_slave_arb_share_counter <= uart_i_avalon_slave_arb_share_counter_next_value;
    end


  //uart_i_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_i_avalon_slave_slavearbiterlockenable <= 0;
      else if ((|uart_i_avalon_slave_master_qreq_vector & end_xfer_arb_share_counter_term_uart_i_avalon_slave) | (end_xfer_arb_share_counter_term_uart_i_avalon_slave & ~uart_i_avalon_slave_non_bursting_master_requests))
          uart_i_avalon_slave_slavearbiterlockenable <= |uart_i_avalon_slave_arb_share_counter_next_value;
    end


  //cpu/data_master uart_i/avalon_slave arbiterlock, which is an e_assign
  assign cpu_data_master_arbiterlock = uart_i_avalon_slave_slavearbiterlockenable & cpu_data_master_continuerequest;

  //uart_i_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign uart_i_avalon_slave_slavearbiterlockenable2 = |uart_i_avalon_slave_arb_share_counter_next_value;

  //cpu/data_master uart_i/avalon_slave arbiterlock2, which is an e_assign
  assign cpu_data_master_arbiterlock2 = uart_i_avalon_slave_slavearbiterlockenable2 & cpu_data_master_continuerequest;

  //uart_i_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign uart_i_avalon_slave_any_continuerequest = 1;

  //cpu_data_master_continuerequest continued request, which is an e_assign
  assign cpu_data_master_continuerequest = 1;

  assign cpu_data_master_qualified_request_uart_i_avalon_slave = cpu_data_master_requests_uart_i_avalon_slave & ~((cpu_data_master_read & (~cpu_data_master_waitrequest)) | ((~cpu_data_master_waitrequest) & cpu_data_master_write));
  //uart_i_avalon_slave_writedata mux, which is an e_mux
  assign uart_i_avalon_slave_writedata = cpu_data_master_writedata;

  //master is always granted when requested
  assign cpu_data_master_granted_uart_i_avalon_slave = cpu_data_master_qualified_request_uart_i_avalon_slave;

  //cpu/data_master saved-grant uart_i/avalon_slave, which is an e_assign
  assign cpu_data_master_saved_grant_uart_i_avalon_slave = cpu_data_master_requests_uart_i_avalon_slave;

  //allow new arb cycle for uart_i/avalon_slave, which is an e_assign
  assign uart_i_avalon_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign uart_i_avalon_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign uart_i_avalon_slave_master_qreq_vector = 1;

  //~uart_i_avalon_slave_reset assignment, which is an e_assign
  assign uart_i_avalon_slave_reset = ~reset_n;

  //uart_i_avalon_slave_firsttransfer first transaction, which is an e_assign
  assign uart_i_avalon_slave_firsttransfer = uart_i_avalon_slave_begins_xfer ? uart_i_avalon_slave_unreg_firsttransfer : uart_i_avalon_slave_reg_firsttransfer;

  //uart_i_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign uart_i_avalon_slave_unreg_firsttransfer = ~(uart_i_avalon_slave_slavearbiterlockenable & uart_i_avalon_slave_any_continuerequest);

  //uart_i_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_i_avalon_slave_reg_firsttransfer <= 1'b1;
      else if (uart_i_avalon_slave_begins_xfer)
          uart_i_avalon_slave_reg_firsttransfer <= uart_i_avalon_slave_unreg_firsttransfer;
    end


  //uart_i_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign uart_i_avalon_slave_beginbursttransfer_internal = uart_i_avalon_slave_begins_xfer;

  //uart_i_avalon_slave_read assignment, which is an e_mux
  assign uart_i_avalon_slave_read = cpu_data_master_granted_uart_i_avalon_slave & cpu_data_master_read;

  //uart_i_avalon_slave_write assignment, which is an e_mux
  assign uart_i_avalon_slave_write = cpu_data_master_granted_uart_i_avalon_slave & cpu_data_master_write;

  assign shifted_address_to_uart_i_avalon_slave_from_cpu_data_master = cpu_data_master_address_to_slave;
  //d1_uart_i_avalon_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_uart_i_avalon_slave_end_xfer <= 1;
      else 
        d1_uart_i_avalon_slave_end_xfer <= uart_i_avalon_slave_end_xfer;
    end


  //uart_i_avalon_slave_waits_for_read in a cycle, which is an e_mux
  assign uart_i_avalon_slave_waits_for_read = uart_i_avalon_slave_in_a_read_cycle & uart_i_avalon_slave_waitrequest_from_sa;

  //uart_i_avalon_slave_in_a_read_cycle assignment, which is an e_assign
  assign uart_i_avalon_slave_in_a_read_cycle = cpu_data_master_granted_uart_i_avalon_slave & cpu_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = uart_i_avalon_slave_in_a_read_cycle;

  //uart_i_avalon_slave_waits_for_write in a cycle, which is an e_mux
  assign uart_i_avalon_slave_waits_for_write = uart_i_avalon_slave_in_a_write_cycle & uart_i_avalon_slave_waitrequest_from_sa;

  //uart_i_avalon_slave_in_a_write_cycle assignment, which is an e_assign
  assign uart_i_avalon_slave_in_a_write_cycle = cpu_data_master_granted_uart_i_avalon_slave & cpu_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = uart_i_avalon_slave_in_a_write_cycle;

  assign wait_for_uart_i_avalon_slave_counter = 0;
  //assign uart_i_avalon_slave_irq_from_sa = uart_i_avalon_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_i_avalon_slave_irq_from_sa = uart_i_avalon_slave_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //uart_i/avalon_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module DE1_soc_nios_reset_clk_0_domain_synch_module (
                                                      // inputs:
                                                       clk,
                                                       data_in,
                                                       reset_n,

                                                      // outputs:
                                                       data_out
                                                    )
;

  output           data_out;
  input            clk;
  input            data_in;
  input            reset_n;

  reg              data_in_d1 /* synthesis ALTERA_ATTRIBUTE = "{-from \"*\"} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  reg              data_out /* synthesis ALTERA_ATTRIBUTE = "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_in_d1 <= 0;
      else 
        data_in_d1 <= data_in;
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_out <= 0;
      else 
        data_out <= data_in_d1;
    end



endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module DE1_soc_nios (
                      // 1) global signals:
                       clk_0,
                       reset_n,

                      // the_stopwatch_i
                       b_clr_to_the_stopwatch_i,
                       b_run_to_the_stopwatch_i,
                       b_tmp_to_the_stopwatch_i,
                       s_hld_from_the_stopwatch_i,
                       s_run_from_the_stopwatch_i,
                       t_mil_0_from_the_stopwatch_i,
                       t_mil_1_from_the_stopwatch_i,
                       t_mil_2_from_the_stopwatch_i,
                       t_min_0_from_the_stopwatch_i,
                       t_min_1_from_the_stopwatch_i,
                       t_sec_0_from_the_stopwatch_i,
                       t_sec_1_from_the_stopwatch_i,

                      // the_uart_i
                       uart_rxd_to_the_uart_i,
                       uart_txd_from_the_uart_i
                    )
;

  output           s_hld_from_the_stopwatch_i;
  output           s_run_from_the_stopwatch_i;
  output  [  3: 0] t_mil_0_from_the_stopwatch_i;
  output  [  3: 0] t_mil_1_from_the_stopwatch_i;
  output  [  3: 0] t_mil_2_from_the_stopwatch_i;
  output  [  3: 0] t_min_0_from_the_stopwatch_i;
  output  [  3: 0] t_min_1_from_the_stopwatch_i;
  output  [  3: 0] t_sec_0_from_the_stopwatch_i;
  output  [  3: 0] t_sec_1_from_the_stopwatch_i;
  output           uart_txd_from_the_uart_i;
  input            b_clr_to_the_stopwatch_i;
  input            b_run_to_the_stopwatch_i;
  input            b_tmp_to_the_stopwatch_i;
  input            clk_0;
  input            reset_n;
  input            uart_rxd_to_the_uart_i;

  wire             clk_0_reset_n;
  wire    [ 18: 0] cpu_data_master_address;
  wire    [ 18: 0] cpu_data_master_address_to_slave;
  wire    [  3: 0] cpu_data_master_byteenable;
  wire             cpu_data_master_debugaccess;
  wire             cpu_data_master_granted_cpu_jtag_debug_module;
  wire             cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_granted_onchip_memory_s1;
  wire             cpu_data_master_granted_stopwatch_i_avalon_slave;
  wire             cpu_data_master_granted_uart_i_avalon_slave;
  wire    [ 31: 0] cpu_data_master_irq;
  wire             cpu_data_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_qualified_request_onchip_memory_s1;
  wire             cpu_data_master_qualified_request_stopwatch_i_avalon_slave;
  wire             cpu_data_master_qualified_request_uart_i_avalon_slave;
  wire             cpu_data_master_read;
  wire             cpu_data_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_read_data_valid_onchip_memory_s1;
  wire             cpu_data_master_read_data_valid_stopwatch_i_avalon_slave;
  wire             cpu_data_master_read_data_valid_uart_i_avalon_slave;
  wire    [ 31: 0] cpu_data_master_readdata;
  wire             cpu_data_master_requests_cpu_jtag_debug_module;
  wire             cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  wire             cpu_data_master_requests_onchip_memory_s1;
  wire             cpu_data_master_requests_stopwatch_i_avalon_slave;
  wire             cpu_data_master_requests_uart_i_avalon_slave;
  wire             cpu_data_master_waitrequest;
  wire             cpu_data_master_write;
  wire    [ 31: 0] cpu_data_master_writedata;
  wire    [ 18: 0] cpu_instruction_master_address;
  wire    [ 18: 0] cpu_instruction_master_address_to_slave;
  wire             cpu_instruction_master_granted_cpu_jtag_debug_module;
  wire             cpu_instruction_master_granted_onchip_memory_s1;
  wire             cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  wire             cpu_instruction_master_qualified_request_onchip_memory_s1;
  wire             cpu_instruction_master_read;
  wire             cpu_instruction_master_read_data_valid_cpu_jtag_debug_module;
  wire             cpu_instruction_master_read_data_valid_onchip_memory_s1;
  wire    [ 31: 0] cpu_instruction_master_readdata;
  wire             cpu_instruction_master_requests_cpu_jtag_debug_module;
  wire             cpu_instruction_master_requests_onchip_memory_s1;
  wire             cpu_instruction_master_waitrequest;
  wire    [  8: 0] cpu_jtag_debug_module_address;
  wire             cpu_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_jtag_debug_module_byteenable;
  wire             cpu_jtag_debug_module_chipselect;
  wire             cpu_jtag_debug_module_debugaccess;
  wire    [ 31: 0] cpu_jtag_debug_module_readdata;
  wire    [ 31: 0] cpu_jtag_debug_module_readdata_from_sa;
  wire             cpu_jtag_debug_module_reset_n;
  wire             cpu_jtag_debug_module_resetrequest;
  wire             cpu_jtag_debug_module_resetrequest_from_sa;
  wire             cpu_jtag_debug_module_write;
  wire    [ 31: 0] cpu_jtag_debug_module_writedata;
  wire             d1_cpu_jtag_debug_module_end_xfer;
  wire             d1_jtag_uart_avalon_jtag_slave_end_xfer;
  wire             d1_onchip_memory_s1_end_xfer;
  wire             d1_stopwatch_i_avalon_slave_end_xfer;
  wire             d1_uart_i_avalon_slave_end_xfer;
  wire             jtag_uart_avalon_jtag_slave_address;
  wire             jtag_uart_avalon_jtag_slave_chipselect;
  wire             jtag_uart_avalon_jtag_slave_dataavailable;
  wire             jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_avalon_jtag_slave_irq;
  wire             jtag_uart_avalon_jtag_slave_irq_from_sa;
  wire             jtag_uart_avalon_jtag_slave_read_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_readdata;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_readdata_from_sa;
  wire             jtag_uart_avalon_jtag_slave_readyfordata;
  wire             jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  wire             jtag_uart_avalon_jtag_slave_reset_n;
  wire             jtag_uart_avalon_jtag_slave_waitrequest;
  wire             jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  wire             jtag_uart_avalon_jtag_slave_write_n;
  wire    [ 31: 0] jtag_uart_avalon_jtag_slave_writedata;
  wire    [ 14: 0] onchip_memory_s1_address;
  wire    [  3: 0] onchip_memory_s1_byteenable;
  wire             onchip_memory_s1_chipselect;
  wire             onchip_memory_s1_clken;
  wire    [ 31: 0] onchip_memory_s1_readdata;
  wire    [ 31: 0] onchip_memory_s1_readdata_from_sa;
  wire             onchip_memory_s1_write;
  wire    [ 31: 0] onchip_memory_s1_writedata;
  wire             registered_cpu_data_master_read_data_valid_onchip_memory_s1;
  wire             reset_n_sources;
  wire             s_hld_from_the_stopwatch_i;
  wire             s_run_from_the_stopwatch_i;
  wire             stopwatch_i_avalon_slave_irq;
  wire             stopwatch_i_avalon_slave_irq_from_sa;
  wire             stopwatch_i_avalon_slave_read;
  wire    [ 31: 0] stopwatch_i_avalon_slave_readdata;
  wire    [ 31: 0] stopwatch_i_avalon_slave_readdata_from_sa;
  wire             stopwatch_i_avalon_slave_reset;
  wire             stopwatch_i_avalon_slave_write;
  wire    [ 31: 0] stopwatch_i_avalon_slave_writedata;
  wire    [  3: 0] t_mil_0_from_the_stopwatch_i;
  wire    [  3: 0] t_mil_1_from_the_stopwatch_i;
  wire    [  3: 0] t_mil_2_from_the_stopwatch_i;
  wire    [  3: 0] t_min_0_from_the_stopwatch_i;
  wire    [  3: 0] t_min_1_from_the_stopwatch_i;
  wire    [  3: 0] t_sec_0_from_the_stopwatch_i;
  wire    [  3: 0] t_sec_1_from_the_stopwatch_i;
  wire             uart_i_avalon_slave_irq;
  wire             uart_i_avalon_slave_irq_from_sa;
  wire             uart_i_avalon_slave_read;
  wire    [ 31: 0] uart_i_avalon_slave_readdata;
  wire    [ 31: 0] uart_i_avalon_slave_readdata_from_sa;
  wire             uart_i_avalon_slave_reset;
  wire             uart_i_avalon_slave_waitrequest;
  wire             uart_i_avalon_slave_waitrequest_from_sa;
  wire             uart_i_avalon_slave_write;
  wire    [ 31: 0] uart_i_avalon_slave_writedata;
  wire             uart_txd_from_the_uart_i;
  cpu_jtag_debug_module_arbitrator the_cpu_jtag_debug_module
    (
      .clk                                                            (clk_0),
      .cpu_data_master_address_to_slave                               (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable                                     (cpu_data_master_byteenable),
      .cpu_data_master_debugaccess                                    (cpu_data_master_debugaccess),
      .cpu_data_master_granted_cpu_jtag_debug_module                  (cpu_data_master_granted_cpu_jtag_debug_module),
      .cpu_data_master_qualified_request_cpu_jtag_debug_module        (cpu_data_master_qualified_request_cpu_jtag_debug_module),
      .cpu_data_master_read                                           (cpu_data_master_read),
      .cpu_data_master_read_data_valid_cpu_jtag_debug_module          (cpu_data_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_data_master_requests_cpu_jtag_debug_module                 (cpu_data_master_requests_cpu_jtag_debug_module),
      .cpu_data_master_waitrequest                                    (cpu_data_master_waitrequest),
      .cpu_data_master_write                                          (cpu_data_master_write),
      .cpu_data_master_writedata                                      (cpu_data_master_writedata),
      .cpu_instruction_master_address_to_slave                        (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_granted_cpu_jtag_debug_module           (cpu_instruction_master_granted_cpu_jtag_debug_module),
      .cpu_instruction_master_qualified_request_cpu_jtag_debug_module (cpu_instruction_master_qualified_request_cpu_jtag_debug_module),
      .cpu_instruction_master_read                                    (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_cpu_jtag_debug_module   (cpu_instruction_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_instruction_master_requests_cpu_jtag_debug_module          (cpu_instruction_master_requests_cpu_jtag_debug_module),
      .cpu_jtag_debug_module_address                                  (cpu_jtag_debug_module_address),
      .cpu_jtag_debug_module_begintransfer                            (cpu_jtag_debug_module_begintransfer),
      .cpu_jtag_debug_module_byteenable                               (cpu_jtag_debug_module_byteenable),
      .cpu_jtag_debug_module_chipselect                               (cpu_jtag_debug_module_chipselect),
      .cpu_jtag_debug_module_debugaccess                              (cpu_jtag_debug_module_debugaccess),
      .cpu_jtag_debug_module_readdata                                 (cpu_jtag_debug_module_readdata),
      .cpu_jtag_debug_module_readdata_from_sa                         (cpu_jtag_debug_module_readdata_from_sa),
      .cpu_jtag_debug_module_reset_n                                  (cpu_jtag_debug_module_reset_n),
      .cpu_jtag_debug_module_resetrequest                             (cpu_jtag_debug_module_resetrequest),
      .cpu_jtag_debug_module_resetrequest_from_sa                     (cpu_jtag_debug_module_resetrequest_from_sa),
      .cpu_jtag_debug_module_write                                    (cpu_jtag_debug_module_write),
      .cpu_jtag_debug_module_writedata                                (cpu_jtag_debug_module_writedata),
      .d1_cpu_jtag_debug_module_end_xfer                              (d1_cpu_jtag_debug_module_end_xfer),
      .reset_n                                                        (clk_0_reset_n)
    );

  cpu_data_master_arbitrator the_cpu_data_master
    (
      .clk                                                           (clk_0),
      .cpu_data_master_address                                       (cpu_data_master_address),
      .cpu_data_master_address_to_slave                              (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_cpu_jtag_debug_module                 (cpu_data_master_granted_cpu_jtag_debug_module),
      .cpu_data_master_granted_jtag_uart_avalon_jtag_slave           (cpu_data_master_granted_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_granted_onchip_memory_s1                      (cpu_data_master_granted_onchip_memory_s1),
      .cpu_data_master_granted_stopwatch_i_avalon_slave              (cpu_data_master_granted_stopwatch_i_avalon_slave),
      .cpu_data_master_granted_uart_i_avalon_slave                   (cpu_data_master_granted_uart_i_avalon_slave),
      .cpu_data_master_irq                                           (cpu_data_master_irq),
      .cpu_data_master_qualified_request_cpu_jtag_debug_module       (cpu_data_master_qualified_request_cpu_jtag_debug_module),
      .cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave (cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_qualified_request_onchip_memory_s1            (cpu_data_master_qualified_request_onchip_memory_s1),
      .cpu_data_master_qualified_request_stopwatch_i_avalon_slave    (cpu_data_master_qualified_request_stopwatch_i_avalon_slave),
      .cpu_data_master_qualified_request_uart_i_avalon_slave         (cpu_data_master_qualified_request_uart_i_avalon_slave),
      .cpu_data_master_read                                          (cpu_data_master_read),
      .cpu_data_master_read_data_valid_cpu_jtag_debug_module         (cpu_data_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave   (cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_read_data_valid_onchip_memory_s1              (cpu_data_master_read_data_valid_onchip_memory_s1),
      .cpu_data_master_read_data_valid_stopwatch_i_avalon_slave      (cpu_data_master_read_data_valid_stopwatch_i_avalon_slave),
      .cpu_data_master_read_data_valid_uart_i_avalon_slave           (cpu_data_master_read_data_valid_uart_i_avalon_slave),
      .cpu_data_master_readdata                                      (cpu_data_master_readdata),
      .cpu_data_master_requests_cpu_jtag_debug_module                (cpu_data_master_requests_cpu_jtag_debug_module),
      .cpu_data_master_requests_jtag_uart_avalon_jtag_slave          (cpu_data_master_requests_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_requests_onchip_memory_s1                     (cpu_data_master_requests_onchip_memory_s1),
      .cpu_data_master_requests_stopwatch_i_avalon_slave             (cpu_data_master_requests_stopwatch_i_avalon_slave),
      .cpu_data_master_requests_uart_i_avalon_slave                  (cpu_data_master_requests_uart_i_avalon_slave),
      .cpu_data_master_waitrequest                                   (cpu_data_master_waitrequest),
      .cpu_data_master_write                                         (cpu_data_master_write),
      .cpu_jtag_debug_module_readdata_from_sa                        (cpu_jtag_debug_module_readdata_from_sa),
      .d1_cpu_jtag_debug_module_end_xfer                             (d1_cpu_jtag_debug_module_end_xfer),
      .d1_jtag_uart_avalon_jtag_slave_end_xfer                       (d1_jtag_uart_avalon_jtag_slave_end_xfer),
      .d1_onchip_memory_s1_end_xfer                                  (d1_onchip_memory_s1_end_xfer),
      .d1_stopwatch_i_avalon_slave_end_xfer                          (d1_stopwatch_i_avalon_slave_end_xfer),
      .d1_uart_i_avalon_slave_end_xfer                               (d1_uart_i_avalon_slave_end_xfer),
      .jtag_uart_avalon_jtag_slave_irq_from_sa                       (jtag_uart_avalon_jtag_slave_irq_from_sa),
      .jtag_uart_avalon_jtag_slave_readdata_from_sa                  (jtag_uart_avalon_jtag_slave_readdata_from_sa),
      .jtag_uart_avalon_jtag_slave_waitrequest_from_sa               (jtag_uart_avalon_jtag_slave_waitrequest_from_sa),
      .onchip_memory_s1_readdata_from_sa                             (onchip_memory_s1_readdata_from_sa),
      .registered_cpu_data_master_read_data_valid_onchip_memory_s1   (registered_cpu_data_master_read_data_valid_onchip_memory_s1),
      .reset_n                                                       (clk_0_reset_n),
      .stopwatch_i_avalon_slave_irq_from_sa                          (stopwatch_i_avalon_slave_irq_from_sa),
      .stopwatch_i_avalon_slave_readdata_from_sa                     (stopwatch_i_avalon_slave_readdata_from_sa),
      .uart_i_avalon_slave_irq_from_sa                               (uart_i_avalon_slave_irq_from_sa),
      .uart_i_avalon_slave_readdata_from_sa                          (uart_i_avalon_slave_readdata_from_sa),
      .uart_i_avalon_slave_waitrequest_from_sa                       (uart_i_avalon_slave_waitrequest_from_sa)
    );

  cpu_instruction_master_arbitrator the_cpu_instruction_master
    (
      .clk                                                            (clk_0),
      .cpu_instruction_master_address                                 (cpu_instruction_master_address),
      .cpu_instruction_master_address_to_slave                        (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_granted_cpu_jtag_debug_module           (cpu_instruction_master_granted_cpu_jtag_debug_module),
      .cpu_instruction_master_granted_onchip_memory_s1                (cpu_instruction_master_granted_onchip_memory_s1),
      .cpu_instruction_master_qualified_request_cpu_jtag_debug_module (cpu_instruction_master_qualified_request_cpu_jtag_debug_module),
      .cpu_instruction_master_qualified_request_onchip_memory_s1      (cpu_instruction_master_qualified_request_onchip_memory_s1),
      .cpu_instruction_master_read                                    (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_cpu_jtag_debug_module   (cpu_instruction_master_read_data_valid_cpu_jtag_debug_module),
      .cpu_instruction_master_read_data_valid_onchip_memory_s1        (cpu_instruction_master_read_data_valid_onchip_memory_s1),
      .cpu_instruction_master_readdata                                (cpu_instruction_master_readdata),
      .cpu_instruction_master_requests_cpu_jtag_debug_module          (cpu_instruction_master_requests_cpu_jtag_debug_module),
      .cpu_instruction_master_requests_onchip_memory_s1               (cpu_instruction_master_requests_onchip_memory_s1),
      .cpu_instruction_master_waitrequest                             (cpu_instruction_master_waitrequest),
      .cpu_jtag_debug_module_readdata_from_sa                         (cpu_jtag_debug_module_readdata_from_sa),
      .d1_cpu_jtag_debug_module_end_xfer                              (d1_cpu_jtag_debug_module_end_xfer),
      .d1_onchip_memory_s1_end_xfer                                   (d1_onchip_memory_s1_end_xfer),
      .onchip_memory_s1_readdata_from_sa                              (onchip_memory_s1_readdata_from_sa),
      .reset_n                                                        (clk_0_reset_n)
    );

  cpu the_cpu
    (
      .clk                                   (clk_0),
      .d_address                             (cpu_data_master_address),
      .d_byteenable                          (cpu_data_master_byteenable),
      .d_irq                                 (cpu_data_master_irq),
      .d_read                                (cpu_data_master_read),
      .d_readdata                            (cpu_data_master_readdata),
      .d_waitrequest                         (cpu_data_master_waitrequest),
      .d_write                               (cpu_data_master_write),
      .d_writedata                           (cpu_data_master_writedata),
      .i_address                             (cpu_instruction_master_address),
      .i_read                                (cpu_instruction_master_read),
      .i_readdata                            (cpu_instruction_master_readdata),
      .i_waitrequest                         (cpu_instruction_master_waitrequest),
      .jtag_debug_module_address             (cpu_jtag_debug_module_address),
      .jtag_debug_module_begintransfer       (cpu_jtag_debug_module_begintransfer),
      .jtag_debug_module_byteenable          (cpu_jtag_debug_module_byteenable),
      .jtag_debug_module_debugaccess         (cpu_jtag_debug_module_debugaccess),
      .jtag_debug_module_debugaccess_to_roms (cpu_data_master_debugaccess),
      .jtag_debug_module_readdata            (cpu_jtag_debug_module_readdata),
      .jtag_debug_module_resetrequest        (cpu_jtag_debug_module_resetrequest),
      .jtag_debug_module_select              (cpu_jtag_debug_module_chipselect),
      .jtag_debug_module_write               (cpu_jtag_debug_module_write),
      .jtag_debug_module_writedata           (cpu_jtag_debug_module_writedata),
      .reset_n                               (cpu_jtag_debug_module_reset_n)
    );

  jtag_uart_avalon_jtag_slave_arbitrator the_jtag_uart_avalon_jtag_slave
    (
      .clk                                                           (clk_0),
      .cpu_data_master_address_to_slave                              (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_jtag_uart_avalon_jtag_slave           (cpu_data_master_granted_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave (cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_read                                          (cpu_data_master_read),
      .cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave   (cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_requests_jtag_uart_avalon_jtag_slave          (cpu_data_master_requests_jtag_uart_avalon_jtag_slave),
      .cpu_data_master_waitrequest                                   (cpu_data_master_waitrequest),
      .cpu_data_master_write                                         (cpu_data_master_write),
      .cpu_data_master_writedata                                     (cpu_data_master_writedata),
      .d1_jtag_uart_avalon_jtag_slave_end_xfer                       (d1_jtag_uart_avalon_jtag_slave_end_xfer),
      .jtag_uart_avalon_jtag_slave_address                           (jtag_uart_avalon_jtag_slave_address),
      .jtag_uart_avalon_jtag_slave_chipselect                        (jtag_uart_avalon_jtag_slave_chipselect),
      .jtag_uart_avalon_jtag_slave_dataavailable                     (jtag_uart_avalon_jtag_slave_dataavailable),
      .jtag_uart_avalon_jtag_slave_dataavailable_from_sa             (jtag_uart_avalon_jtag_slave_dataavailable_from_sa),
      .jtag_uart_avalon_jtag_slave_irq                               (jtag_uart_avalon_jtag_slave_irq),
      .jtag_uart_avalon_jtag_slave_irq_from_sa                       (jtag_uart_avalon_jtag_slave_irq_from_sa),
      .jtag_uart_avalon_jtag_slave_read_n                            (jtag_uart_avalon_jtag_slave_read_n),
      .jtag_uart_avalon_jtag_slave_readdata                          (jtag_uart_avalon_jtag_slave_readdata),
      .jtag_uart_avalon_jtag_slave_readdata_from_sa                  (jtag_uart_avalon_jtag_slave_readdata_from_sa),
      .jtag_uart_avalon_jtag_slave_readyfordata                      (jtag_uart_avalon_jtag_slave_readyfordata),
      .jtag_uart_avalon_jtag_slave_readyfordata_from_sa              (jtag_uart_avalon_jtag_slave_readyfordata_from_sa),
      .jtag_uart_avalon_jtag_slave_reset_n                           (jtag_uart_avalon_jtag_slave_reset_n),
      .jtag_uart_avalon_jtag_slave_waitrequest                       (jtag_uart_avalon_jtag_slave_waitrequest),
      .jtag_uart_avalon_jtag_slave_waitrequest_from_sa               (jtag_uart_avalon_jtag_slave_waitrequest_from_sa),
      .jtag_uart_avalon_jtag_slave_write_n                           (jtag_uart_avalon_jtag_slave_write_n),
      .jtag_uart_avalon_jtag_slave_writedata                         (jtag_uart_avalon_jtag_slave_writedata),
      .reset_n                                                       (clk_0_reset_n)
    );

  jtag_uart the_jtag_uart
    (
      .av_address     (jtag_uart_avalon_jtag_slave_address),
      .av_chipselect  (jtag_uart_avalon_jtag_slave_chipselect),
      .av_irq         (jtag_uart_avalon_jtag_slave_irq),
      .av_read_n      (jtag_uart_avalon_jtag_slave_read_n),
      .av_readdata    (jtag_uart_avalon_jtag_slave_readdata),
      .av_waitrequest (jtag_uart_avalon_jtag_slave_waitrequest),
      .av_write_n     (jtag_uart_avalon_jtag_slave_write_n),
      .av_writedata   (jtag_uart_avalon_jtag_slave_writedata),
      .clk            (clk_0),
      .dataavailable  (jtag_uart_avalon_jtag_slave_dataavailable),
      .readyfordata   (jtag_uart_avalon_jtag_slave_readyfordata),
      .rst_n          (jtag_uart_avalon_jtag_slave_reset_n)
    );

  onchip_memory_s1_arbitrator the_onchip_memory_s1
    (
      .clk                                                         (clk_0),
      .cpu_data_master_address_to_slave                            (cpu_data_master_address_to_slave),
      .cpu_data_master_byteenable                                  (cpu_data_master_byteenable),
      .cpu_data_master_granted_onchip_memory_s1                    (cpu_data_master_granted_onchip_memory_s1),
      .cpu_data_master_qualified_request_onchip_memory_s1          (cpu_data_master_qualified_request_onchip_memory_s1),
      .cpu_data_master_read                                        (cpu_data_master_read),
      .cpu_data_master_read_data_valid_onchip_memory_s1            (cpu_data_master_read_data_valid_onchip_memory_s1),
      .cpu_data_master_requests_onchip_memory_s1                   (cpu_data_master_requests_onchip_memory_s1),
      .cpu_data_master_waitrequest                                 (cpu_data_master_waitrequest),
      .cpu_data_master_write                                       (cpu_data_master_write),
      .cpu_data_master_writedata                                   (cpu_data_master_writedata),
      .cpu_instruction_master_address_to_slave                     (cpu_instruction_master_address_to_slave),
      .cpu_instruction_master_granted_onchip_memory_s1             (cpu_instruction_master_granted_onchip_memory_s1),
      .cpu_instruction_master_qualified_request_onchip_memory_s1   (cpu_instruction_master_qualified_request_onchip_memory_s1),
      .cpu_instruction_master_read                                 (cpu_instruction_master_read),
      .cpu_instruction_master_read_data_valid_onchip_memory_s1     (cpu_instruction_master_read_data_valid_onchip_memory_s1),
      .cpu_instruction_master_requests_onchip_memory_s1            (cpu_instruction_master_requests_onchip_memory_s1),
      .d1_onchip_memory_s1_end_xfer                                (d1_onchip_memory_s1_end_xfer),
      .onchip_memory_s1_address                                    (onchip_memory_s1_address),
      .onchip_memory_s1_byteenable                                 (onchip_memory_s1_byteenable),
      .onchip_memory_s1_chipselect                                 (onchip_memory_s1_chipselect),
      .onchip_memory_s1_clken                                      (onchip_memory_s1_clken),
      .onchip_memory_s1_readdata                                   (onchip_memory_s1_readdata),
      .onchip_memory_s1_readdata_from_sa                           (onchip_memory_s1_readdata_from_sa),
      .onchip_memory_s1_write                                      (onchip_memory_s1_write),
      .onchip_memory_s1_writedata                                  (onchip_memory_s1_writedata),
      .registered_cpu_data_master_read_data_valid_onchip_memory_s1 (registered_cpu_data_master_read_data_valid_onchip_memory_s1),
      .reset_n                                                     (clk_0_reset_n)
    );

  onchip_memory the_onchip_memory
    (
      .address    (onchip_memory_s1_address),
      .byteenable (onchip_memory_s1_byteenable),
      .chipselect (onchip_memory_s1_chipselect),
      .clk        (clk_0),
      .clken      (onchip_memory_s1_clken),
      .readdata   (onchip_memory_s1_readdata),
      .write      (onchip_memory_s1_write),
      .writedata  (onchip_memory_s1_writedata)
    );

  stopwatch_i_avalon_slave_arbitrator the_stopwatch_i_avalon_slave
    (
      .clk                                                        (clk_0),
      .cpu_data_master_address_to_slave                           (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_stopwatch_i_avalon_slave           (cpu_data_master_granted_stopwatch_i_avalon_slave),
      .cpu_data_master_qualified_request_stopwatch_i_avalon_slave (cpu_data_master_qualified_request_stopwatch_i_avalon_slave),
      .cpu_data_master_read                                       (cpu_data_master_read),
      .cpu_data_master_read_data_valid_stopwatch_i_avalon_slave   (cpu_data_master_read_data_valid_stopwatch_i_avalon_slave),
      .cpu_data_master_requests_stopwatch_i_avalon_slave          (cpu_data_master_requests_stopwatch_i_avalon_slave),
      .cpu_data_master_waitrequest                                (cpu_data_master_waitrequest),
      .cpu_data_master_write                                      (cpu_data_master_write),
      .cpu_data_master_writedata                                  (cpu_data_master_writedata),
      .d1_stopwatch_i_avalon_slave_end_xfer                       (d1_stopwatch_i_avalon_slave_end_xfer),
      .reset_n                                                    (clk_0_reset_n),
      .stopwatch_i_avalon_slave_irq                               (stopwatch_i_avalon_slave_irq),
      .stopwatch_i_avalon_slave_irq_from_sa                       (stopwatch_i_avalon_slave_irq_from_sa),
      .stopwatch_i_avalon_slave_read                              (stopwatch_i_avalon_slave_read),
      .stopwatch_i_avalon_slave_readdata                          (stopwatch_i_avalon_slave_readdata),
      .stopwatch_i_avalon_slave_readdata_from_sa                  (stopwatch_i_avalon_slave_readdata_from_sa),
      .stopwatch_i_avalon_slave_reset                             (stopwatch_i_avalon_slave_reset),
      .stopwatch_i_avalon_slave_write                             (stopwatch_i_avalon_slave_write),
      .stopwatch_i_avalon_slave_writedata                         (stopwatch_i_avalon_slave_writedata)
    );

  stopwatch_i the_stopwatch_i
    (
      .avalon_interrupt (stopwatch_i_avalon_slave_irq),
      .avalon_read      (stopwatch_i_avalon_slave_read),
      .avalon_readdata  (stopwatch_i_avalon_slave_readdata),
      .avalon_write     (stopwatch_i_avalon_slave_write),
      .avalon_writedata (stopwatch_i_avalon_slave_writedata),
      .b_clr            (b_clr_to_the_stopwatch_i),
      .b_run            (b_run_to_the_stopwatch_i),
      .b_tmp            (b_tmp_to_the_stopwatch_i),
      .clk              (clk_0),
      .rst              (stopwatch_i_avalon_slave_reset),
      .s_hld            (s_hld_from_the_stopwatch_i),
      .s_run            (s_run_from_the_stopwatch_i),
      .t_mil_0          (t_mil_0_from_the_stopwatch_i),
      .t_mil_1          (t_mil_1_from_the_stopwatch_i),
      .t_mil_2          (t_mil_2_from_the_stopwatch_i),
      .t_min_0          (t_min_0_from_the_stopwatch_i),
      .t_min_1          (t_min_1_from_the_stopwatch_i),
      .t_sec_0          (t_sec_0_from_the_stopwatch_i),
      .t_sec_1          (t_sec_1_from_the_stopwatch_i)
    );

  uart_i_avalon_slave_arbitrator the_uart_i_avalon_slave
    (
      .clk                                                   (clk_0),
      .cpu_data_master_address_to_slave                      (cpu_data_master_address_to_slave),
      .cpu_data_master_granted_uart_i_avalon_slave           (cpu_data_master_granted_uart_i_avalon_slave),
      .cpu_data_master_qualified_request_uart_i_avalon_slave (cpu_data_master_qualified_request_uart_i_avalon_slave),
      .cpu_data_master_read                                  (cpu_data_master_read),
      .cpu_data_master_read_data_valid_uart_i_avalon_slave   (cpu_data_master_read_data_valid_uart_i_avalon_slave),
      .cpu_data_master_requests_uart_i_avalon_slave          (cpu_data_master_requests_uart_i_avalon_slave),
      .cpu_data_master_waitrequest                           (cpu_data_master_waitrequest),
      .cpu_data_master_write                                 (cpu_data_master_write),
      .cpu_data_master_writedata                             (cpu_data_master_writedata),
      .d1_uart_i_avalon_slave_end_xfer                       (d1_uart_i_avalon_slave_end_xfer),
      .reset_n                                               (clk_0_reset_n),
      .uart_i_avalon_slave_irq                               (uart_i_avalon_slave_irq),
      .uart_i_avalon_slave_irq_from_sa                       (uart_i_avalon_slave_irq_from_sa),
      .uart_i_avalon_slave_read                              (uart_i_avalon_slave_read),
      .uart_i_avalon_slave_readdata                          (uart_i_avalon_slave_readdata),
      .uart_i_avalon_slave_readdata_from_sa                  (uart_i_avalon_slave_readdata_from_sa),
      .uart_i_avalon_slave_reset                             (uart_i_avalon_slave_reset),
      .uart_i_avalon_slave_waitrequest                       (uart_i_avalon_slave_waitrequest),
      .uart_i_avalon_slave_waitrequest_from_sa               (uart_i_avalon_slave_waitrequest_from_sa),
      .uart_i_avalon_slave_write                             (uart_i_avalon_slave_write),
      .uart_i_avalon_slave_writedata                         (uart_i_avalon_slave_writedata)
    );

  uart_i the_uart_i
    (
      .avalon_interrupt   (uart_i_avalon_slave_irq),
      .avalon_read        (uart_i_avalon_slave_read),
      .avalon_readdata    (uart_i_avalon_slave_readdata),
      .avalon_waitrequest (uart_i_avalon_slave_waitrequest),
      .avalon_write       (uart_i_avalon_slave_write),
      .avalon_writedata   (uart_i_avalon_slave_writedata),
      .clk                (clk_0),
      .rst                (uart_i_avalon_slave_reset),
      .uart_rxd           (uart_rxd_to_the_uart_i),
      .uart_txd           (uart_txd_from_the_uart_i)
    );

  //reset is asserted asynchronously and deasserted synchronously
  DE1_soc_nios_reset_clk_0_domain_synch_module DE1_soc_nios_reset_clk_0_domain_synch
    (
      .clk      (clk_0),
      .data_in  (1'b1),
      .data_out (clk_0_reset_n),
      .reset_n  (reset_n_sources)
    );

  //reset sources mux, which is an e_mux
  assign reset_n_sources = ~(~reset_n |
    0 |
    cpu_jtag_debug_module_resetrequest_from_sa |
    cpu_jtag_debug_module_resetrequest_from_sa);


endmodule


//synthesis translate_off



// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE

// AND HERE WILL BE PRESERVED </ALTERA_NOTE>


// If user logic components use Altsync_Ram with convert_hex2ver.dll,
// set USE_convert_hex2ver in the user comments section above

// `ifdef USE_convert_hex2ver
// `else
// `define NO_PLI 1
// `endif

`include "/opt/altera9.1/quartus/eda/sim_lib/altera_mf.v"
`include "/opt/altera9.1/quartus/eda/sim_lib/220model.v"
`include "/opt/altera9.1/quartus/eda/sim_lib/sgate.v"
`include "/home/izi/Workplace/fpga-hdl/hdl/uart/uart.v"
`include "uart_i.v"
`include "/home/izi/Workplace/fpga-hdl/hdl/stopwatch/stopwatch.v"
`include "stopwatch_i.v"
`include "onchip_memory.v"
`include "cpu_test_bench.v"
`include "cpu_oci_test_bench.v"
`include "cpu_jtag_debug_module_tck.v"
`include "cpu_jtag_debug_module_sysclk.v"
`include "cpu_jtag_debug_module_wrapper.v"
`include "cpu.v"
`include "jtag_uart.v"

`timescale 1ns / 1ps

module test_bench 
;


  wire             b_clr_to_the_stopwatch_i;
  wire             b_run_to_the_stopwatch_i;
  wire             b_tmp_to_the_stopwatch_i;
  wire             clk;
  reg              clk_0;
  wire             jtag_uart_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_avalon_jtag_slave_readyfordata_from_sa;
  reg              reset_n;
  wire             s_hld_from_the_stopwatch_i;
  wire             s_run_from_the_stopwatch_i;
  wire    [  3: 0] t_mil_0_from_the_stopwatch_i;
  wire    [  3: 0] t_mil_1_from_the_stopwatch_i;
  wire    [  3: 0] t_mil_2_from_the_stopwatch_i;
  wire    [  3: 0] t_min_0_from_the_stopwatch_i;
  wire    [  3: 0] t_min_1_from_the_stopwatch_i;
  wire    [  3: 0] t_sec_0_from_the_stopwatch_i;
  wire    [  3: 0] t_sec_1_from_the_stopwatch_i;
  wire             uart_rxd_to_the_uart_i;
  wire             uart_txd_from_the_uart_i;


// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
//  add your signals and additional architecture here
// AND HERE WILL BE PRESERVED </ALTERA_NOTE>

  //Set us up the Dut
  DE1_soc_nios DUT
    (
      .b_clr_to_the_stopwatch_i     (b_clr_to_the_stopwatch_i),
      .b_run_to_the_stopwatch_i     (b_run_to_the_stopwatch_i),
      .b_tmp_to_the_stopwatch_i     (b_tmp_to_the_stopwatch_i),
      .clk_0                        (clk_0),
      .reset_n                      (reset_n),
      .s_hld_from_the_stopwatch_i   (s_hld_from_the_stopwatch_i),
      .s_run_from_the_stopwatch_i   (s_run_from_the_stopwatch_i),
      .t_mil_0_from_the_stopwatch_i (t_mil_0_from_the_stopwatch_i),
      .t_mil_1_from_the_stopwatch_i (t_mil_1_from_the_stopwatch_i),
      .t_mil_2_from_the_stopwatch_i (t_mil_2_from_the_stopwatch_i),
      .t_min_0_from_the_stopwatch_i (t_min_0_from_the_stopwatch_i),
      .t_min_1_from_the_stopwatch_i (t_min_1_from_the_stopwatch_i),
      .t_sec_0_from_the_stopwatch_i (t_sec_0_from_the_stopwatch_i),
      .t_sec_1_from_the_stopwatch_i (t_sec_1_from_the_stopwatch_i),
      .uart_rxd_to_the_uart_i       (uart_rxd_to_the_uart_i),
      .uart_txd_from_the_uart_i     (uart_txd_from_the_uart_i)
    );

  initial
    clk_0 = 1'b0;
  always
    #21 clk_0 <= ~clk_0;
  
  initial 
    begin
      reset_n <= 0;
      #420 reset_n <= 1;
    end

endmodule


//synthesis translate_on