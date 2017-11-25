
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name cpu -dir "/home/jackey/My_project/VHDL/cpu/planAhead_run_5" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/jackey/My_project/VHDL/cpu/cpu.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/jackey/My_project/VHDL/cpu} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "test_vga.ucf" [current_fileset -constrset]
add_files [list {test_vga.ucf}] -fileset [get_property constrset [current_run]]
link_design
