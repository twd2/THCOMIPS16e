
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name ex_alu -dir "C:/Users/twd2/Desktop/ex_alu/ex_alu/planAhead_run_2" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/twd2/Desktop/ex_alu/ex_alu/controller.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/twd2/Desktop/ex_alu/ex_alu} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "alu.ucf" [current_fileset -constrset]
add_files [list {alu.ucf}] -fileset [get_property constrset [current_run]]
link_design
