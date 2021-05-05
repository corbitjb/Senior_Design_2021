# 2021 Senior Design Project - Synthetic Aperture Radar (SAR) Imaging Simulator
This is the repository for our senior design project.  
Contributors: Joel Corbitt, Jake Lutch, Nick Holl, Rebecca Stout  
  
This project aims to create a SAR simulator in Matlab.  
The SAR system we created uses a backprojection algorithm to reconstruct images of targets within a predefined target scene. The simulator consists of a GUI that allows users 
to adjust and toggle some features in the simulator. The topic of target recognition using convolutional neural networks was also explored. This part of the project is functional 
but incomplete.  
  
To run the full simulation on your device (excluding the target recognition), the following files must be downloaded:  
SARSimualtor_v5.m  
SigStudioFinal.mlapp  
addTank.m  
addMig.m  
getMult.m  
chirp_v4.m  
bpsk_mod.m  
costas_code.m  
golay2.m  
adaptiveFilter.m  
  
To run the simulation, open the SARSimulator_v5.m file and click run. The GUI will be opened first, and the code will wait on a button press to execute. 
