
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name sopc -dir "C:/Users/twd2/Desktop/thco/THCOMIPS16e/sopc/planAhead_run_2" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/twd2/Desktop/thco/THCOMIPS16e/sopc/mips_sopc_cs.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/twd2/Desktop/thco/THCOMIPS16e/sopc} {ipcore_dir} }
add_files [list {ipcore_dir/fifo.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/font_rom.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/graphics_memory.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/memory.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/rom.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "mips_sopc.ucf" [current_fileset -constrset]
add_files [list {mips_sopc.ucf}] -fileset [get_property constrset [current_run]]
link_design
