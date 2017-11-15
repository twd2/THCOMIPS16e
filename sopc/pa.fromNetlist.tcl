
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name sopc -dir "C:/Users/twd2/Desktop/thco/THCOMIPS16e/sopc/planAhead_run_1" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/twd2/Desktop/thco/THCOMIPS16e/sopc/mips_sopc.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/twd2/Desktop/thco/THCOMIPS16e/sopc} {ipcore_dir} }
add_files [list {ipcore_dir/memory.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/rom.ncf}] -fileset [get_property constrset [current_run]]
set_param project.pinAheadLayout  yes
set_property target_constrs_file "mips_sopc.ucf" [current_fileset -constrset]
add_files [list {mips_sopc.ucf}] -fileset [get_property constrset [current_run]]
link_design
