
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name sram_uart -dir "C:/Users/twd2/Desktop/thco/sram_uart/planAhead_run_1" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/twd2/Desktop/thco/sram_uart/sram_uart.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/twd2/Desktop/thco/sram_uart} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "sram_uart.ucf" [current_fileset -constrset]
add_files [list {sram_uart.ucf}] -fileset [get_property constrset [current_run]]
link_design
