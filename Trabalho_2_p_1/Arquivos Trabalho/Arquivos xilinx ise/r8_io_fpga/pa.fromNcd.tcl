
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name r8_io_fpga -dir "C:/Documents and Settings/dfdfjf/Desktop/projetos_vhdl/r8_io_fpga/planAhead_run_1" -part xc6slx16csg324-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "C:/Documents and Settings/dfdfjf/Desktop/projetos_vhdl/r8_io_fpga/R8_uC.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Documents and Settings/dfdfjf/Desktop/projetos_vhdl/r8_io_fpga} }
set_property target_constrs_file "constraints.ucf" [current_fileset -constrset]
add_files [list {constraints.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "C:/Documents and Settings/dfdfjf/Desktop/projetos_vhdl/r8_io_fpga/R8_uC.ncd"
if {[catch {read_twx -name results_1 -file "C:/Documents and Settings/dfdfjf/Desktop/projetos_vhdl/r8_io_fpga/R8_uC.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"C:/Documents and Settings/dfdfjf/Desktop/projetos_vhdl/r8_io_fpga/R8_uC.twx\": $eInfo"
}
