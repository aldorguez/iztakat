# Iztakat
MAAS HPC cluster

Configuration files and scripts for the setup of a MAAS based HPC cluster.

- 00.maas.sh: Sets up the MAAS server.
  
- 01.nfs.server.sh: Installs the nfs server and exports the /share, /scratch and /home folders.
   
- 02.tcltk.install.sh: Downloads and installs the tcl/tk libraries, necesary for the instalation of environment-modules.
  
- 03.modules.install.sh: Downloads and installs envoronment-modules.
  
- 04.slurm.server.sh: Installs the slurm server using the config files in the slurm folder.
   
- commissioning-scripts/
  - maas-cpu-ubuntu.sh: MAAS commissioning script for compute node deployment.
     
  - maas-gpu-ubuntu.sh: MAAS commissioning script for GPU compute node deployment.

