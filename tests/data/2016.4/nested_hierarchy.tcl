
################################################################
# This is a generated script based on design: nested_hierarchy
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
# source nested_hierarchy_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART xilinx.com:zc702:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name nested_hierarchy

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

# Hierarchical cell: layer1
proc create_hier_cell_layer1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_layer1() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DRAM1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi1

  # Create pins
  create_bd_pin -dir I gpio_in
  create_bd_pin -dir I gpio_in1
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

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
  create_hier_cell_layer2 $hier_obj layer2

  # Create instance: middle, and set properties
  set middle [ create_bd_cell -type ip -vlnv user.org:user:pynq_test:1.0 middle ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins s_axi1] [get_bd_intf_pins layer1_interrupts/s_axi]
  connect_bd_intf_net -intf_net inner_M_AXI_DRAM [get_bd_intf_pins M_AXI_DRAM] [get_bd_intf_pins layer2/M_AXI_DRAM]
  connect_bd_intf_net -intf_net middle_M_AXI_DRAM [get_bd_intf_pins M_AXI_DRAM1] [get_bd_intf_pins middle/M_AXI_DRAM]
  connect_bd_intf_net -intf_net middle_M_AXI_OUT [get_bd_intf_pins middle/M_AXI_OUT] [get_bd_intf_pins middle/S_AXI_IN]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins S_AXI_CTRL] [get_bd_intf_pins layer2/S_AXI_CTRL]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M02_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins layer2/s_axi]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M03_AXI [get_bd_intf_pins S_AXI_CTRL1] [get_bd_intf_pins middle/S_AXI_CTRL]

  # Create port connections
  connect_bd_net -net axi_intc_0_irq [get_bd_pins layer1_concat/In2] [get_bd_pins layer2/irq]
  connect_bd_net -net axi_intc_1_irq [get_bd_pins irq] [get_bd_pins layer1_interrupts/irq]
  connect_bd_net -net middle_interrupt_bus [get_bd_pins layer1_concat/In0] [get_bd_pins middle/interrupt_bus]
  connect_bd_net -net middle_interrupt_wire [get_bd_pins layer1_concat/In1] [get_bd_pins middle/interrupt_wire]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins s_axi_aclk] [get_bd_pins layer1_interrupts/s_axi_aclk] [get_bd_pins layer2/clock] [get_bd_pins middle/clock]
  connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins layer1_interrupts/s_axi_aresetn] [get_bd_pins layer2/reset_n] [get_bd_pins middle/reset_n]
  connect_bd_net -net slice_middle_Dout [get_bd_pins gpio_in1] [get_bd_pins middle/gpio_in]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins layer1_concat/dout] [get_bd_pins layer1_interrupts/intr]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins gpio_in] [get_bd_pins layer2/gpio_in]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /layer1] -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port s_axi_aclk -pg 1 -y 290 -defaultsOSRD
preplace port S_AXI_CTRL1 -pg 1 -y 60 -defaultsOSRD
preplace port M_AXI_DRAM -pg 1 -y 210 -defaultsOSRD
preplace port gpio_in -pg 1 -y 270 -defaultsOSRD
preplace port S_AXI_CTRL -pg 1 -y 210 -defaultsOSRD
preplace port s_axi -pg 1 -y 160 -defaultsOSRD
preplace port s_axi_aresetn -pg 1 -y 310 -defaultsOSRD
preplace port s_axi1 -pg 1 -y 250 -defaultsOSRD
preplace port irq -pg 1 -y 290 -defaultsOSRD
preplace port M_AXI_DRAM1 -pg 1 -y 60 -defaultsOSRD
preplace port gpio_in1 -pg 1 -y 120 -defaultsOSRD
preplace inst layer2|layer2_concat -pg 1 -lvl 2 -y 348 -defaultsOSRD
preplace inst layer1_concat -pg 1 -lvl 3 -y 380 -defaultsOSRD
preplace inst layer2 -pg 1 -lvl 1 -y 248 -defaultsOSRD
preplace inst layer2|layer2_interrupts -pg 1 -lvl 3 -y 448 -defaultsOSRD
preplace inst layer1_interrupts -pg 1 -lvl 2 -y 280 -defaultsOSRD
preplace inst layer2|inner -pg 1 -lvl 1 -y 308 -defaultsOSRD
preplace inst middle -pg 1 -lvl 3 -y 30 -defaultsOSRD
preplace netloc Conn1 1 0 2 -70J 550 1080J
preplace netloc ps7_0_axi_periph_M02_AXI 1 0 1 -40J
preplace netloc layer2|inner_M_AXI_OUT 1 0 2 150 208 510
preplace netloc layer2|xlslice_0_Dout 1 0 1 N
preplace netloc middle_M_AXI_OUT 1 2 2 1390 -70 1780
preplace netloc xlconcat_1_dout 1 1 3 1090 360 1370J 310 1780
preplace netloc ps7_0_axi_periph_M03_AXI 1 0 3 -70J -20 NJ -20 NJ
preplace netloc middle_interrupt_bus 1 2 2 1380 -90 1790
preplace netloc layer2|ps7_0_axi_periph_M01_AXI 1 0 1 N
preplace netloc layer2|inner_interrupt_wire 1 1 1 N
preplace netloc ps7_0_axi_periph_M01_AXI 1 0 1 -60J
preplace netloc layer2|ps7_0_axi_periph_M02_AXI 1 0 3 140J 418 NJ 418 N
preplace netloc layer2|axi_intc_0_irq 1 3 1 N
preplace netloc layer2|xlconcat_0_dout 1 2 1 700
preplace netloc middle_M_AXI_DRAM 1 3 1 1800J
preplace netloc layer2|inner_interrupt_bus 1 1 1 N
preplace netloc axi_intc_1_irq 1 2 2 NJ 280 1790
preplace netloc rst_ps7_0_50M_peripheral_aresetn 1 0 3 -30 80 1050J 80 N
preplace netloc inner_M_AXI_DRAM 1 1 3 1060J 200 NJ 200 1790J
preplace netloc middle_interrupt_wire 1 2 2 1390 130 1780
preplace netloc processing_system7_0_FCLK_CLK0 1 0 3 -50 60 1070J 60 N
preplace netloc layer2|processing_system7_0_FCLK_CLK0 1 0 3 130 438 NJ 438 N
preplace netloc axi_intc_0_irq 1 1 2 NJ 448 1380
preplace netloc slice_middle_Dout 1 0 3 -60J 40 NJ 40 NJ
preplace netloc layer2|inner_M_AXI_DRAM 1 1 3 N 258 NJ 258 NJ
preplace netloc layer2|rst_ps7_0_50M_peripheral_aresetn 1 0 3 120 458 NJ 458 N
preplace netloc xlslice_0_Dout 1 0 1 -80J
levelinfo -pg 1 -100 200 1269 1599 1820 -top -100 -bot 570
levelinfo -hier layer2 * 330 610 820 *
",
}

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
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
CONFIG.NUM_SI {3} \
 ] $axi_mem_intercon

  # Create instance: layer1
  create_hier_cell_layer1 [current_bd_instance .] layer1

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {23.809523} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {25.000000} \
CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
CONFIG.PCW_CAN0_CAN0_IO {MIO 46 .. 47} \
CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN0_GRP_CLK_IO {<Select>} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_CAN1_CAN1_IO {<Select>} \
CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
CONFIG.PCW_CAN1_GRP_CLK_IO {<Select>} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {7} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {6} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {23.8095} \
CONFIG.PCW_CAN_PERIPHERAL_VALID {1} \
CONFIG.PCW_CLK1_FREQ {10000000} \
CONFIG.PCW_CLK2_FREQ {10000000} \
CONFIG.PCW_CLK3_FREQ {10000000} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_READPORT_3 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2 {<Select>} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3 {<Select>} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {5} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {100 Mbps} \
CONFIG.PCW_ENET0_RESET_ENABLE {1} \
CONFIG.PCW_ENET0_RESET_IO {MIO 11} \
CONFIG.PCW_ENET1_ENET1_IO {<Select>} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
CONFIG.PCW_ENET1_GRP_MDIO_IO {<Select>} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
CONFIG.PCW_ENET1_RESET_ENABLE {0} \
CONFIG.PCW_ENET1_RESET_IO {<Select>} \
CONFIG.PCW_ENET_RESET_ENABLE {1} \
CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
CONFIG.PCW_EN_4K_TIMER {0} \
CONFIG.PCW_EN_CAN0 {1} \
CONFIG.PCW_EN_EMIO_GPIO {1} \
CONFIG.PCW_EN_EMIO_TTC0 {1} \
CONFIG.PCW_EN_ENET0 {1} \
CONFIG.PCW_EN_I2C0 {1} \
CONFIG.PCW_EN_QSPI {1} \
CONFIG.PCW_EN_SDIO0 {1} \
CONFIG.PCW_EN_TTC0 {1} \
CONFIG.PCW_EN_UART1 {1} \
CONFIG.PCW_EN_USB0 {1} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {4} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
CONFIG.PCW_FCLK_CLK1_BUF {FALSE} \
CONFIG.PCW_FCLK_CLK2_BUF {FALSE} \
CONFIG.PCW_FCLK_CLK3_BUF {FALSE} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
CONFIG.PCW_FTM_CTI_IN0 {<Select>} \
CONFIG.PCW_FTM_CTI_IN1 {<Select>} \
CONFIG.PCW_FTM_CTI_IN2 {<Select>} \
CONFIG.PCW_FTM_CTI_IN3 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT0 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT1 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT2 {<Select>} \
CONFIG.PCW_FTM_CTI_OUT3 {<Select>} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C0_GRP_INT_IO {<Select>} \
CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_I2C0_RESET_ENABLE {1} \
CONFIG.PCW_I2C0_RESET_IO {MIO 13} \
CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} \
CONFIG.PCW_I2C1_GRP_INT_IO {<Select>} \
CONFIG.PCW_I2C1_I2C1_IO {<Select>} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_ENABLE {0} \
CONFIG.PCW_I2C1_RESET_IO {<Select>} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
CONFIG.PCW_I2C_RESET_ENABLE {1} \
CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
CONFIG.PCW_IRQ_F2P_INTR {1} \
CONFIG.PCW_MIO_0_DIRECTION {in} \
CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_0_PULLUP {enabled} \
CONFIG.PCW_MIO_0_SLEW {slow} \
CONFIG.PCW_MIO_10_DIRECTION {inout} \
CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_10_PULLUP {enabled} \
CONFIG.PCW_MIO_10_SLEW {slow} \
CONFIG.PCW_MIO_11_DIRECTION {out} \
CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_11_PULLUP {enabled} \
CONFIG.PCW_MIO_11_SLEW {slow} \
CONFIG.PCW_MIO_12_DIRECTION {inout} \
CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_12_PULLUP {enabled} \
CONFIG.PCW_MIO_12_SLEW {slow} \
CONFIG.PCW_MIO_13_DIRECTION {out} \
CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_13_PULLUP {enabled} \
CONFIG.PCW_MIO_13_SLEW {slow} \
CONFIG.PCW_MIO_14_DIRECTION {inout} \
CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_14_PULLUP {enabled} \
CONFIG.PCW_MIO_14_SLEW {slow} \
CONFIG.PCW_MIO_15_DIRECTION {in} \
CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_15_PULLUP {enabled} \
CONFIG.PCW_MIO_15_SLEW {slow} \
CONFIG.PCW_MIO_16_DIRECTION {out} \
CONFIG.PCW_MIO_16_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_16_PULLUP {disabled} \
CONFIG.PCW_MIO_16_SLEW {slow} \
CONFIG.PCW_MIO_17_DIRECTION {out} \
CONFIG.PCW_MIO_17_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_17_PULLUP {disabled} \
CONFIG.PCW_MIO_17_SLEW {slow} \
CONFIG.PCW_MIO_18_DIRECTION {out} \
CONFIG.PCW_MIO_18_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_18_PULLUP {disabled} \
CONFIG.PCW_MIO_18_SLEW {slow} \
CONFIG.PCW_MIO_19_DIRECTION {out} \
CONFIG.PCW_MIO_19_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_19_PULLUP {disabled} \
CONFIG.PCW_MIO_19_SLEW {slow} \
CONFIG.PCW_MIO_1_DIRECTION {out} \
CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_1_PULLUP {enabled} \
CONFIG.PCW_MIO_1_SLEW {slow} \
CONFIG.PCW_MIO_20_DIRECTION {out} \
CONFIG.PCW_MIO_20_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_20_PULLUP {disabled} \
CONFIG.PCW_MIO_20_SLEW {slow} \
CONFIG.PCW_MIO_21_DIRECTION {out} \
CONFIG.PCW_MIO_21_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_21_PULLUP {disabled} \
CONFIG.PCW_MIO_21_SLEW {slow} \
CONFIG.PCW_MIO_22_DIRECTION {in} \
CONFIG.PCW_MIO_22_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_22_PULLUP {disabled} \
CONFIG.PCW_MIO_22_SLEW {slow} \
CONFIG.PCW_MIO_23_DIRECTION {in} \
CONFIG.PCW_MIO_23_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_23_PULLUP {disabled} \
CONFIG.PCW_MIO_23_SLEW {slow} \
CONFIG.PCW_MIO_24_DIRECTION {in} \
CONFIG.PCW_MIO_24_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_24_PULLUP {disabled} \
CONFIG.PCW_MIO_24_SLEW {slow} \
CONFIG.PCW_MIO_25_DIRECTION {in} \
CONFIG.PCW_MIO_25_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_25_PULLUP {disabled} \
CONFIG.PCW_MIO_25_SLEW {slow} \
CONFIG.PCW_MIO_26_DIRECTION {in} \
CONFIG.PCW_MIO_26_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_26_PULLUP {disabled} \
CONFIG.PCW_MIO_26_SLEW {slow} \
CONFIG.PCW_MIO_27_DIRECTION {in} \
CONFIG.PCW_MIO_27_IOTYPE {HSTL 1.8V} \
CONFIG.PCW_MIO_27_PULLUP {disabled} \
CONFIG.PCW_MIO_27_SLEW {slow} \
CONFIG.PCW_MIO_28_DIRECTION {inout} \
CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_28_PULLUP {disabled} \
CONFIG.PCW_MIO_28_SLEW {slow} \
CONFIG.PCW_MIO_29_DIRECTION {in} \
CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_29_PULLUP {disabled} \
CONFIG.PCW_MIO_29_SLEW {slow} \
CONFIG.PCW_MIO_2_DIRECTION {inout} \
CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_2_PULLUP {disabled} \
CONFIG.PCW_MIO_2_SLEW {slow} \
CONFIG.PCW_MIO_30_DIRECTION {out} \
CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_30_PULLUP {disabled} \
CONFIG.PCW_MIO_30_SLEW {slow} \
CONFIG.PCW_MIO_31_DIRECTION {in} \
CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_31_PULLUP {disabled} \
CONFIG.PCW_MIO_31_SLEW {slow} \
CONFIG.PCW_MIO_32_DIRECTION {inout} \
CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_32_PULLUP {disabled} \
CONFIG.PCW_MIO_32_SLEW {slow} \
CONFIG.PCW_MIO_33_DIRECTION {inout} \
CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_33_PULLUP {disabled} \
CONFIG.PCW_MIO_33_SLEW {slow} \
CONFIG.PCW_MIO_34_DIRECTION {inout} \
CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_34_PULLUP {disabled} \
CONFIG.PCW_MIO_34_SLEW {slow} \
CONFIG.PCW_MIO_35_DIRECTION {inout} \
CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_35_PULLUP {disabled} \
CONFIG.PCW_MIO_35_SLEW {slow} \
CONFIG.PCW_MIO_36_DIRECTION {in} \
CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_36_PULLUP {disabled} \
CONFIG.PCW_MIO_36_SLEW {slow} \
CONFIG.PCW_MIO_37_DIRECTION {inout} \
CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_37_PULLUP {disabled} \
CONFIG.PCW_MIO_37_SLEW {slow} \
CONFIG.PCW_MIO_38_DIRECTION {inout} \
CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_38_PULLUP {disabled} \
CONFIG.PCW_MIO_38_SLEW {slow} \
CONFIG.PCW_MIO_39_DIRECTION {inout} \
CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_39_PULLUP {disabled} \
CONFIG.PCW_MIO_39_SLEW {slow} \
CONFIG.PCW_MIO_3_DIRECTION {inout} \
CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_3_PULLUP {disabled} \
CONFIG.PCW_MIO_3_SLEW {slow} \
CONFIG.PCW_MIO_40_DIRECTION {inout} \
CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_40_PULLUP {disabled} \
CONFIG.PCW_MIO_40_SLEW {slow} \
CONFIG.PCW_MIO_41_DIRECTION {inout} \
CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_41_PULLUP {disabled} \
CONFIG.PCW_MIO_41_SLEW {slow} \
CONFIG.PCW_MIO_42_DIRECTION {inout} \
CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_42_PULLUP {disabled} \
CONFIG.PCW_MIO_42_SLEW {slow} \
CONFIG.PCW_MIO_43_DIRECTION {inout} \
CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_43_PULLUP {disabled} \
CONFIG.PCW_MIO_43_SLEW {slow} \
CONFIG.PCW_MIO_44_DIRECTION {inout} \
CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_44_PULLUP {disabled} \
CONFIG.PCW_MIO_44_SLEW {slow} \
CONFIG.PCW_MIO_45_DIRECTION {inout} \
CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_45_PULLUP {disabled} \
CONFIG.PCW_MIO_45_SLEW {slow} \
CONFIG.PCW_MIO_46_DIRECTION {in} \
CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_46_PULLUP {enabled} \
CONFIG.PCW_MIO_46_SLEW {slow} \
CONFIG.PCW_MIO_47_DIRECTION {out} \
CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_47_PULLUP {enabled} \
CONFIG.PCW_MIO_47_SLEW {slow} \
CONFIG.PCW_MIO_48_DIRECTION {out} \
CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_48_PULLUP {disabled} \
CONFIG.PCW_MIO_48_SLEW {slow} \
CONFIG.PCW_MIO_49_DIRECTION {in} \
CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_49_PULLUP {disabled} \
CONFIG.PCW_MIO_49_SLEW {slow} \
CONFIG.PCW_MIO_4_DIRECTION {inout} \
CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_4_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {slow} \
CONFIG.PCW_MIO_50_DIRECTION {inout} \
CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_50_PULLUP {enabled} \
CONFIG.PCW_MIO_50_SLEW {slow} \
CONFIG.PCW_MIO_51_DIRECTION {inout} \
CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_51_PULLUP {enabled} \
CONFIG.PCW_MIO_51_SLEW {slow} \
CONFIG.PCW_MIO_52_DIRECTION {out} \
CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_52_PULLUP {disabled} \
CONFIG.PCW_MIO_52_SLEW {slow} \
CONFIG.PCW_MIO_53_DIRECTION {inout} \
CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_53_PULLUP {disabled} \
CONFIG.PCW_MIO_53_SLEW {slow} \
CONFIG.PCW_MIO_5_DIRECTION {inout} \
CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_5_PULLUP {disabled} \
CONFIG.PCW_MIO_5_SLEW {slow} \
CONFIG.PCW_MIO_6_DIRECTION {out} \
CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_6_PULLUP {disabled} \
CONFIG.PCW_MIO_6_SLEW {slow} \
CONFIG.PCW_MIO_7_DIRECTION {out} \
CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_7_PULLUP {disabled} \
CONFIG.PCW_MIO_7_SLEW {slow} \
CONFIG.PCW_MIO_8_DIRECTION {out} \
CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_8_PULLUP {disabled} \
CONFIG.PCW_MIO_8_SLEW {slow} \
CONFIG.PCW_MIO_9_DIRECTION {inout} \
CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_9_PULLUP {enabled} \
CONFIG.PCW_MIO_9_SLEW {slow} \
CONFIG.PCW_MIO_TREE_PERIPHERALS {SD 0#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#USB Reset#Quad SPI Flash#GPIO#GPIO#ENET Reset#GPIO#I2C Reset#GPIO#SD 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#CAN 0#CAN 0#UART 1#UART 1#I2C 0#I2C 0#Enet 0#Enet 0} \
CONFIG.PCW_MIO_TREE_SIGNALS {cd#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_sclk#reset#qspi_fbclk#gpio[9]#gpio[10]#reset#gpio[12]#reset#gpio[14]#wp#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#rx#tx#tx#rx#scl#sda#mdc#mdio} \
CONFIG.PCW_NAND_CYCLES_T_AR {1} \
CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
CONFIG.PCW_NAND_CYCLES_T_RC {11} \
CONFIG.PCW_NAND_CYCLES_T_REA {1} \
CONFIG.PCW_NAND_CYCLES_T_RR {1} \
CONFIG.PCW_NAND_CYCLES_T_WC {11} \
CONFIG.PCW_NAND_CYCLES_T_WP {1} \
CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
CONFIG.PCW_NAND_GRP_D8_IO {<Select>} \
CONFIG.PCW_NAND_NAND_IO {<Select>} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_CS0_T_CEOE {1} \
CONFIG.PCW_NOR_CS0_T_PC {1} \
CONFIG.PCW_NOR_CS0_T_RC {11} \
CONFIG.PCW_NOR_CS0_T_TR {1} \
CONFIG.PCW_NOR_CS0_T_WC {11} \
CONFIG.PCW_NOR_CS0_T_WP {1} \
CONFIG.PCW_NOR_CS0_WE_TIME {0} \
CONFIG.PCW_NOR_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_CS1_T_PC {1} \
CONFIG.PCW_NOR_CS1_T_RC {11} \
CONFIG.PCW_NOR_CS1_T_TR {1} \
CONFIG.PCW_NOR_CS1_T_WC {11} \
CONFIG.PCW_NOR_CS1_T_WP {1} \
CONFIG.PCW_NOR_CS1_WE_TIME {0} \
CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
CONFIG.PCW_NOR_GRP_A25_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_IO {<Select>} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
CONFIG.PCW_NOR_GRP_SRAM_INT_IO {<Select>} \
CONFIG.PCW_NOR_NOR_IO {<Select>} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.063} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.062} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.065} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.083} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.007} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.010} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.048} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_PERIPHERAL_BOARD_PRESET {part0} \
CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_PJTAG_PJTAG_IO {<Select>} \
CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_IO1_IO {<Select>} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
CONFIG.PCW_QSPI_GRP_SS1_IO {<Select>} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 0} \
CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD0_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_GRP_WP_IO {MIO 15} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
CONFIG.PCW_SD1_GRP_CD_ENABLE {0} \
CONFIG.PCW_SD1_GRP_CD_IO {<Select>} \
CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
CONFIG.PCW_SD1_GRP_POW_IO {<Select>} \
CONFIG.PCW_SD1_GRP_WP_ENABLE {0} \
CONFIG.PCW_SD1_GRP_WP_IO {<Select>} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SD1_SD1_IO {<Select>} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE {0} \
CONFIG.PCW_SPI0_GRP_SS0_IO {<Select>} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE {0} \
CONFIG.PCW_SPI0_GRP_SS1_IO {<Select>} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE {0} \
CONFIG.PCW_SPI0_GRP_SS2_IO {<Select>} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SPI0_SPI0_IO {<Select>} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE {0} \
CONFIG.PCW_SPI1_GRP_SS0_IO {<Select>} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
CONFIG.PCW_SPI1_GRP_SS1_IO {<Select>} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
CONFIG.PCW_SPI1_GRP_SS2_IO {<Select>} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SPI1_SPI1_IO {<Select>} \
CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_16BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_2BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_32BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_4BIT_IO {<Select>} \
CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} \
CONFIG.PCW_TRACE_GRP_8BIT_IO {<Select>} \
CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TRACE_TRACE_IO {<Select>} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_TTC1_TTC1_IO {<Select>} \
CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART0_BAUD_RATE {115200} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART0_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART0_UART0_IO {<Select>} \
CONFIG.PCW_UART1_BAUD_RATE {115200} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
CONFIG.PCW_UART1_GRP_FULL_IO {<Select>} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {20} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
CONFIG.PCW_UIPARAM_DDR_AL {0} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
CONFIG.PCW_UIPARAM_DDR_BL {8} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.537} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.442} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.464} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.521} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
CONFIG.PCW_UIPARAM_DDR_CL {7} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {61.0905} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {61.0905} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {61.0905} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {61.0905} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
CONFIG.PCW_UIPARAM_DDR_CWL {6} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {2048 MBits} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {68.4725} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {71.086} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {66.794} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {108.7385} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.217} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.133} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.089} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.248} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {64.1705} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {63.686} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {68.46} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {105.4895} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {8 Bits} \
CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M8 HX-15E} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_UIPARAM_DDR_T_FAW {30.0} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {36.0} \
CONFIG.PCW_UIPARAM_DDR_T_RC {49.5} \
CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB0_RESET_ENABLE {1} \
CONFIG.PCW_USB0_RESET_IO {MIO 7} \
CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} \
CONFIG.PCW_USB1_RESET_ENABLE {0} \
CONFIG.PCW_USB1_RESET_IO {<Select>} \
CONFIG.PCW_USB1_USB1_IO {<Select>} \
CONFIG.PCW_USB_RESET_ENABLE {1} \
CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
CONFIG.PCW_USE_CROSS_TRIGGER {0} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
CONFIG.PCW_USE_S_AXI_HP0 {1} \
CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
CONFIG.PCW_WDT_WDT_IO {<Select>} \
CONFIG.preset {ZC702} \
 ] $processing_system7_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_APU_CLK_RATIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ARMPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_CAN0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_GRP_CLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_GRP_CLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_CAN1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_GRP_CLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_GRP_CLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CAN_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK1_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK2_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CLK3_FREQ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_CPU_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDRPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_DDR_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT0_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT1_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT2_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PORT3_HPR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_READPORT_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_PRIORITY_WRITEPORT_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_ENET0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_GRP_MDIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_ENET1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_GRP_MDIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_GRP_MDIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_ENET_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_4K_TIMER.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_CAN0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_GPIO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_EMIO_TTC0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_ENET0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_I2C0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_QSPI.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_SDIO0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_TTC0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_UART1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_EN_USB0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK0_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK1_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK2_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FCLK_CLK3_BUF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FPGA_FCLK0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_IN3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_FTM_CTI_OUT3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_MIO_GPIO_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_GPIO_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_GRP_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_GRP_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_I2C0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_GRP_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_GRP_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_I2C1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_I2C_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_IOPLL_CTRL_FBDIV.VALUE_SRC {DEFAULT} \
CONFIG.PCW_IO_IO_PLL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_0_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_10_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_11_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_12_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_13_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_14_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_15_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_16_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_17_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_18_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_19_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_1_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_20_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_21_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_22_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_23_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_24_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_25_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_26_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_27_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_28_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_29_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_2_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_30_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_31_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_32_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_33_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_34_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_35_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_36_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_37_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_38_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_39_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_3_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_40_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_41_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_42_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_43_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_44_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_45_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_46_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_47_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_48_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_49_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_4_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_50_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_51_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_52_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_53_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_5_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_6_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_7_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_8_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_DIRECTION.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_IOTYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_PULLUP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_9_SLEW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_TREE_PERIPHERALS.VALUE_SRC {DEFAULT} \
CONFIG.PCW_MIO_TREE_SIGNALS.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_AR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_CLR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_REA.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_RR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_CYCLES_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_GRP_D8_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_GRP_D8_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_NAND_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NAND_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS0_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_CS1_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_A25_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_A25_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_CS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_CS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_GRP_SRAM_INT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_NOR_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS0_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_CEOE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_PC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_TR.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_WC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_T_WP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_NOR_SRAM_CS1_WE_TIME.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PERIPHERAL_BOARD_PRESET.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PJTAG_PJTAG_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PLL_BYPASSMODE_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PRESET_BANK0_VOLTAGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_FBCLK_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_IO1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_IO1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_QSPI_QSPI_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_CD_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_CD_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_POW_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_POW_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_WP_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_GRP_WP_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD0_SD0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_CD_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_CD_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_POW_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_POW_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_WP_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_GRP_WP_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SD1_SD1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SDIO_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_GRP_SS2_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI0_SPI0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS0_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS1_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS2_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_GRP_SS2_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI1_SPI1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP0_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP1_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP2_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_S_AXI_HP3_DATA_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_16BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_16BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_2BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_2BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_32BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_32BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_4BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_4BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_8BIT_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_GRP_8BIT_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_INTERNAL_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TRACE_TRACE_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC0_TTC0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC1_TTC1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_BAUD_RATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_GRP_FULL_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART0_UART0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_BAUD_RATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_GRP_FULL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_GRP_FULL_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART1_UART1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UART_PERIPHERAL_VALID.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_AL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_CWL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ECC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_PARTNO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_SPEED_BIN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_FAW.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RCD.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_T_RP.VALUE_SRC {DEFAULT} \
CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB0_USB0_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_RESET_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB1_USB1_IO.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_POLARITY.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USB_RESET_SELECT.VALUE_SRC {DEFAULT} \
CONFIG.PCW_USE_CROSS_TRIGGER.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_CLKSRC.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_ENABLE.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ.VALUE_SRC {DEFAULT} \
CONFIG.PCW_WDT_WDT_IO.VALUE_SRC {DEFAULT} \
 ] $processing_system7_0

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {5} \
 ] $ps7_0_axi_periph

  # Create instance: pynq_test, and set properties
  set pynq_test [ create_bd_cell -type ip -vlnv user.org:user:pynq_test:1.0 pynq_test ]

  # Create instance: rst_ps7_0_50M, and set properties
  set rst_ps7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_50M ]

  # Create instance: slice_inner, and set properties
  set slice_inner [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_inner ]
  set_property -dict [ list \
CONFIG.DIN_FROM {2} \
CONFIG.DIN_TO {2} \
CONFIG.DIN_WIDTH {64} \
CONFIG.DOUT_WIDTH {1} \
 ] $slice_inner

  # Create instance: slice_middle, and set properties
  set slice_middle [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_middle ]
  set_property -dict [ list \
CONFIG.DIN_FROM {3} \
CONFIG.DIN_TO {3} \
CONFIG.DIN_WIDTH {64} \
CONFIG.DOUT_WIDTH {1} \
 ] $slice_middle

  # Create instance: system_concat, and set properties
  set system_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 system_concat ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {1} \
 ] $system_concat

  # Create interface connections
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net inner_M_AXI_DRAM [get_bd_intf_pins axi_mem_intercon/S01_AXI] [get_bd_intf_pins layer1/M_AXI_DRAM]
  connect_bd_intf_net -intf_net middle_M_AXI_DRAM [get_bd_intf_pins axi_mem_intercon/S02_AXI] [get_bd_intf_pins layer1/M_AXI_DRAM1]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins ps7_0_axi_periph/M00_AXI] [get_bd_intf_pins pynq_test/S_AXI_CTRL]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M01_AXI [get_bd_intf_pins layer1/S_AXI_CTRL] [get_bd_intf_pins ps7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M02_AXI [get_bd_intf_pins layer1/s_axi] [get_bd_intf_pins ps7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M03_AXI [get_bd_intf_pins layer1/S_AXI_CTRL1] [get_bd_intf_pins ps7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M04_AXI [get_bd_intf_pins layer1/s_axi1] [get_bd_intf_pins ps7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net pynq_test_0_M_AXI_DRAM [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins pynq_test/M_AXI_DRAM]
  connect_bd_intf_net -intf_net pynq_test_0_M_AXI_OUT [get_bd_intf_pins pynq_test/M_AXI_OUT] [get_bd_intf_pins pynq_test/S_AXI_IN]

  # Create port connections
  connect_bd_net -net axi_intc_0_irq [get_bd_pins layer1/irq] [get_bd_pins system_concat/In0]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins axi_mem_intercon/S02_ACLK] [get_bd_pins layer1/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/M01_ACLK] [get_bd_pins ps7_0_axi_periph/M02_ACLK] [get_bd_pins ps7_0_axi_periph/M03_ACLK] [get_bd_pins ps7_0_axi_periph/M04_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins pynq_test/clock] [get_bd_pins rst_ps7_0_50M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_50M/ext_reset_in]
  connect_bd_net -net processing_system7_0_GPIO_O [get_bd_pins processing_system7_0/GPIO_O] [get_bd_pins slice_inner/Din] [get_bd_pins slice_middle/Din]
  connect_bd_net -net rst_ps7_0_50M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins ps7_0_axi_periph/ARESETN] [get_bd_pins rst_ps7_0_50M/interconnect_aresetn]
  connect_bd_net -net rst_ps7_0_50M_peripheral_aresetn [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins axi_mem_intercon/S02_ARESETN] [get_bd_pins layer1/s_axi_aresetn] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/M01_ARESETN] [get_bd_pins ps7_0_axi_periph/M02_ARESETN] [get_bd_pins ps7_0_axi_periph/M03_ARESETN] [get_bd_pins ps7_0_axi_periph/M04_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins pynq_test/reset_n] [get_bd_pins rst_ps7_0_50M/peripheral_aresetn]
  connect_bd_net -net slice_middle_Dout [get_bd_pins layer1/gpio_in1] [get_bd_pins slice_middle/Dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins system_concat/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins layer1/gpio_in] [get_bd_pins slice_inner/Dout]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x41800000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs layer1/layer2/layer2_interrupts/S_AXI/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41810000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs layer1/layer1_interrupts/S_AXI/Reg] SEG_axi_intc_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs layer1/layer2/inner/S_AXI_CTRL/S_AXI_CTRL_reg] SEG_inner_S_AXI_CTRL_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C20000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs layer1/middle/S_AXI_CTRL/S_AXI_CTRL_reg] SEG_middle_S_AXI_CTRL_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pynq_test/S_AXI_CTRL/S_AXI_CTRL_reg] SEG_pynq_test_S_AXI_CTRL_reg
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces pynq_test/M_AXI_DRAM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces layer1/middle/M_AXI_DRAM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x00000000 [get_bd_addr_spaces layer1/layer2/inner/M_AXI_DRAM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.6.5b  2016-09-06 bk=1.3687 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port DDR -pg 1 -y 300 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 320 -defaultsOSRD
preplace inst pynq_test -pg 1 -lvl 3 -y 100 -defaultsOSRD
preplace inst rst_ps7_0_50M -pg 1 -lvl 1 -y 630 -defaultsOSRD
preplace inst system_concat -pg 1 -lvl 4 -y 540 -defaultsOSRD
preplace inst slice_middle -pg 1 -lvl 3 -y 840 -defaultsOSRD
preplace inst layer1 -pg 1 -lvl 6 -y 350 -defaultsOSRD
preplace inst ps7_0_axi_periph -pg 1 -lvl 2 -y 370 -defaultsOSRD
preplace inst axi_mem_intercon -pg 1 -lvl 4 -y 190 -defaultsOSRD
preplace inst slice_inner -pg 1 -lvl 2 -y 740 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 5 -y 360 -defaultsOSRD
preplace netloc ps7_0_axi_periph_M02_AXI 1 2 4 690J -40 NJ -40 NJ -40 2000
preplace netloc processing_system7_0_DDR 1 5 4 1960J 210 NJ 210 NJ 210 2430J
preplace netloc pynq_test_0_M_AXI_OUT 1 2 2 720 0 1080
preplace netloc processing_system7_0_GPIO_O 1 1 5 390 690 710J 690 NJ 690 NJ 690 1930
preplace netloc processing_system7_0_M_AXI_GP0 1 1 5 400 -60 NJ -60 NJ -60 NJ -60 1920
preplace netloc xlconcat_1_dout 1 4 1 1440
preplace netloc processing_system7_0_FCLK_RESET0_N 1 0 6 30 540 370J 590 NJ 590 NJ 590 NJ 590 1920
preplace netloc ps7_0_axi_periph_M03_AXI 1 2 4 NJ 390 NJ 390 1420J 200 1980
preplace netloc pynq_test_0_M_AXI_DRAM 1 3 1 1090
preplace netloc axi_mem_intercon_M00_AXI 1 4 1 1440
preplace netloc ps7_0_axi_periph_M01_AXI 1 2 4 NJ 350 1080J 370 1430J 210 1950
preplace netloc rst_ps7_0_50M_interconnect_aresetn 1 1 3 380 650 NJ 650 1090J
preplace netloc middle_M_AXI_DRAM 1 3 4 1120 10 NJ 10 NJ 10 2300
preplace netloc processing_system7_0_FIXED_IO 1 5 4 1970J 220 NJ 220 NJ 220 2420J
preplace netloc rst_ps7_0_50M_peripheral_aresetn 1 1 5 400 670 720 670 1110 670 NJ 670 1990
preplace netloc inner_M_AXI_DRAM 1 3 4 1110 0 NJ 0 NJ 0 2310
preplace netloc ps7_0_axi_periph_M04_AXI 1 2 4 N 410 NJ 410 1410J -30 1990J
preplace netloc processing_system7_0_FCLK_CLK0 1 0 6 20 -10 390 -10 710 -10 1100 -10 1450 -10 1940
preplace netloc ps7_0_axi_periph_M00_AXI 1 2 1 700
preplace netloc slice_middle_Dout 1 3 3 NJ 840 NJ 840 2000
preplace netloc axi_intc_0_irq 1 3 4 1120J 480 1420J 520 NJ 520 2300
preplace netloc xlslice_0_Dout 1 2 4 NJ 740 NJ 740 NJ 740 1970
levelinfo -pg 1 0 200 550 900 1270 1700 2160 2350 2400 2450 -top -70 -bot 890
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


