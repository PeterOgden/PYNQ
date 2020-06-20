
################################################################
# This is a generated script based on design: out_of_context
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source out_of_context_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART xilinx.com:zc702:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name out_of_context

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: layer2
proc create_hier_cell_layer2 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_layer2() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DRAM
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  # Create pins
  create_bd_pin -dir I -type clk clock
  create_bd_pin -dir I gpio_in
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir I -type rst reset_n

  # Create instance: inner, and set properties
  set inner [ create_bd_cell -type ip -vlnv user.org:user:pynq_test:1.0 inner ]

  # Create instance: layer2_concat, and set properties
  set layer2_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 layer2_concat ]

  # Create instance: layer2_interrupts, and set properties
  set layer2_interrupts [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 layer2_interrupts ]
  set_property -dict [ list \
CONFIG.C_IRQ_CONNECTION {1} \
 ] $layer2_interrupts

  # Create interface connections
  connect_bd_intf_net -intf_net inner_M_AXI_DRAM [get_bd_intf_pins M_AXI_DRAM] [get_bd_intf_pins inner/M_AXI_DRAM]
  connect_bd_intf_net -intf_net inner_M_AXI_OUT [get_bd_intf_pins inner/M_AXI_OUT] [get_bd_intf_pins inner/S_AXI_IN]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins S_AXI_CTRL] [get_bd_intf_pins inner/S_AXI_CTRL]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M02_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins layer2_interrupts/s_axi]

  # Create port connections
  connect_bd_net -net axi_intc_0_irq [get_bd_pins irq] [get_bd_pins layer2_interrupts/irq]
  connect_bd_net -net inner_interrupt_bus [get_bd_pins inner/interrupt_bus] [get_bd_pins layer2_concat/In0]
  connect_bd_net -net inner_interrupt_wire [get_bd_pins inner/interrupt_wire] [get_bd_pins layer2_concat/In1]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clock] [get_bd_pins inner/clock] [get_bd_pins layer2_interrupts/s_axi_aclk]
  connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_pins reset_n] [get_bd_pins inner/reset_n] [get_bd_pins layer2_interrupts/s_axi_aresetn]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins layer2_concat/dout] [get_bd_pins layer2_interrupts/intr]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins gpio_in] [get_bd_pins inner/gpio_in]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXI_DRAM [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DRAM ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.DATA_WIDTH {32} \
CONFIG.PROTOCOL {AXI4} \
 ] $M_AXI_DRAM
  set M_AXI_DRAM1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DRAM1 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.DATA_WIDTH {32} \
CONFIG.PROTOCOL {AXI4} \
 ] $M_AXI_DRAM1
  set S00_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {32} \
CONFIG.HAS_BRESP {1} \
CONFIG.HAS_BURST {1} \
CONFIG.HAS_CACHE {1} \
CONFIG.HAS_LOCK {1} \
CONFIG.HAS_PROT {1} \
CONFIG.HAS_QOS {1} \
CONFIG.HAS_REGION {0} \
CONFIG.HAS_RRESP {1} \
CONFIG.HAS_WSTRB {1} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {256} \
CONFIG.NUM_READ_OUTSTANDING {2} \
CONFIG.NUM_READ_THREADS {1} \
CONFIG.NUM_WRITE_OUTSTANDING {2} \
CONFIG.NUM_WRITE_THREADS {1} \
CONFIG.PROTOCOL {AXI4} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
CONFIG.RUSER_BITS_PER_BYTE {0} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {1} \
CONFIG.WUSER_BITS_PER_BYTE {0} \
CONFIG.WUSER_WIDTH {0} \
 ] $S00_AXI

  # Create ports
  set ARESETN [ create_bd_port -dir I -type rst ARESETN ]
  set gpio_in [ create_bd_port -dir I gpio_in ]
  set gpio_in1 [ create_bd_port -dir I gpio_in1 ]
  set irq [ create_bd_port -dir O -type intr irq ]
  set s_axi_aclk [ create_bd_port -dir I -type clk s_axi_aclk ]
  set s_axi_aresetn [ create_bd_port -dir I -type rst s_axi_aresetn ]

  # Create instance: layer1_concat, and set properties
  set layer1_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 layer1_concat ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {3} \
 ] $layer1_concat

  # Create instance: layer1_interrupts, and set properties
  set layer1_interrupts [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 layer1_interrupts ]
  set_property -dict [ list \
CONFIG.C_IRQ_CONNECTION {1} \
 ] $layer1_interrupts

  # Create instance: layer2
  create_hier_cell_layer2 [current_bd_instance .] layer2

  # Create instance: middle, and set properties
  set middle [ create_bd_cell -type ip -vlnv user.org:user:pynq_test:1.0 middle ]

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {5} \
 ] $ps7_0_axi_periph

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_ports S00_AXI] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net S_AXI_CTRL_1 [get_bd_intf_pins layer2/S_AXI_CTRL] [get_bd_intf_pins ps7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net inner_M_AXI_DRAM [get_bd_intf_ports M_AXI_DRAM] [get_bd_intf_pins layer2/M_AXI_DRAM]
  connect_bd_intf_net -intf_net middle_M_AXI_DRAM [get_bd_intf_ports M_AXI_DRAM1] [get_bd_intf_pins middle/M_AXI_DRAM]
  connect_bd_intf_net -intf_net middle_M_AXI_OUT [get_bd_intf_pins middle/M_AXI_OUT] [get_bd_intf_pins middle/S_AXI_IN]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M03_AXI [get_bd_intf_pins middle/S_AXI_CTRL] [get_bd_intf_pins ps7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M04_AXI [get_bd_intf_pins layer1_interrupts/s_axi] [get_bd_intf_pins ps7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins layer2/s_axi] [get_bd_intf_pins ps7_0_axi_periph/M02_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_ports ARESETN] [get_bd_pins ps7_0_axi_periph/ARESETN]
  connect_bd_net -net axi_intc_0_irq [get_bd_pins layer1_concat/In2] [get_bd_pins layer2/irq]
  connect_bd_net -net axi_intc_1_irq [get_bd_ports irq] [get_bd_pins layer1_interrupts/irq]
  connect_bd_net -net middle_interrupt_bus [get_bd_pins layer1_concat/In0] [get_bd_pins middle/interrupt_bus]
  connect_bd_net -net middle_interrupt_wire [get_bd_pins layer1_concat/In1] [get_bd_pins middle/interrupt_wire]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_ports s_axi_aclk] [get_bd_pins layer1_interrupts/s_axi_aclk] [get_bd_pins layer2/clock] [get_bd_pins middle/clock] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/M01_ACLK] [get_bd_pins ps7_0_axi_periph/M02_ACLK] [get_bd_pins ps7_0_axi_periph/M03_ACLK] [get_bd_pins ps7_0_axi_periph/M04_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK]
  connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_ports s_axi_aresetn] [get_bd_pins layer1_interrupts/s_axi_aresetn] [get_bd_pins layer2/reset_n] [get_bd_pins middle/reset_n] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/M01_ARESETN] [get_bd_pins ps7_0_axi_periph/M02_ARESETN] [get_bd_pins ps7_0_axi_periph/M03_ARESETN] [get_bd_pins ps7_0_axi_periph/M04_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN]
  connect_bd_net -net slice_middle_Dout [get_bd_ports gpio_in1] [get_bd_pins middle/gpio_in]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins layer1_concat/dout] [get_bd_pins layer1_interrupts/intr]
  connect_bd_net -net xlslice_0_Dout [get_bd_ports gpio_in] [get_bd_pins layer2/gpio_in]

  # Create address segments
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces middle/M_AXI_DRAM] [get_bd_addr_segs M_AXI_DRAM1/Reg] SEG_M_AXI_DRAM1_Reg
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces layer2/inner/M_AXI_DRAM] [get_bd_addr_segs M_AXI_DRAM/Reg] SEG_M_AXI_DRAM_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs layer2/inner/S_AXI_CTRL/S_AXI_CTRL_reg] SEG_inner_S_AXI_CTRL_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs layer1_interrupts/S_AXI/Reg] SEG_layer1_interrupts_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41210000 [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs layer2/layer2_interrupts/S_AXI/Reg] SEG_layer2_interrupts_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces S00_AXI] [get_bd_addr_segs middle/S_AXI_CTRL/S_AXI_CTRL_reg] SEG_middle_S_AXI_CTRL_reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port s_axi_aclk -pg 1 -y 150 -defaultsOSRD
preplace port M_AXI_DRAM -pg 1 -y 300 -defaultsOSRD
preplace port gpio_in -pg 1 -y 640 -defaultsOSRD
preplace port S00_AXI -pg 1 -y 130 -defaultsOSRD
preplace port ARESETN -pg 1 -y 170 -defaultsOSRD
preplace port s_axi_aresetn -pg 1 -y 210 -defaultsOSRD
preplace port irq -pg 1 -y 490 -defaultsOSRD
preplace port M_AXI_DRAM1 -pg 1 -y 60 -defaultsOSRD
preplace port gpio_in1 -pg 1 -y 620 -defaultsOSRD
preplace inst layer1_concat -pg 1 -lvl 1 -y 560 -defaultsOSRD
preplace inst layer2 -pg 1 -lvl 2 -y 310 -defaultsOSRD
preplace inst ps7_0_axi_periph -pg 1 -lvl 1 -y 270 -defaultsOSRD
preplace inst layer1_interrupts -pg 1 -lvl 2 -y 490 -defaultsOSRD
preplace inst middle -pg 1 -lvl 2 -y 110 -defaultsOSRD
preplace netloc Conn1 1 0 1 NJ
preplace netloc s_axi_1 1 1 1 N
preplace netloc middle_M_AXI_OUT 1 1 2 370 10 780
preplace netloc xlconcat_1_dout 1 1 1 380
preplace netloc ARESETN_1 1 0 1 NJ
preplace netloc ps7_0_axi_periph_M03_AXI 1 1 1 340
preplace netloc S_AXI_CTRL_1 1 1 1 350
preplace netloc middle_interrupt_bus 1 0 3 20 660 NJ 660 780
preplace netloc middle_M_AXI_DRAM 1 2 1 NJ
preplace netloc rst_ps7_0_50M_peripheral_aresetn 1 0 2 40 60 330
preplace netloc axi_intc_1_irq 1 2 1 NJ
preplace netloc inner_M_AXI_DRAM 1 2 1 NJ
preplace netloc middle_interrupt_wire 1 0 3 30 630 NJ 630 770
preplace netloc ps7_0_axi_periph_M04_AXI 1 1 1 320
preplace netloc processing_system7_0_FCLK_CLK0 1 0 2 0 480 360
preplace netloc slice_middle_Dout 1 0 2 10J 70 360J
preplace netloc axi_intc_0_irq 1 0 3 40 650 NJ 650 760
preplace netloc xlslice_0_Dout 1 0 2 NJ 640 370J
levelinfo -pg 1 -20 180 580 800 -top 0 -bot 670
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


