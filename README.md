# Domain_Adapting_CSI_WiFi_Mapping
The CSI-based fine-tuning localization system consists of several modules and algorithms that work together to achieve accurate localization. The system incorporates a domain adapting module, a triangulation method, a Human Activity Recognition (HAR) algorithm, and real-time trajectory plotting.
The main.m file serves as the entry point for executing the code. It orchestrates the overall workflow of the localization system. The code relies on the Signal Processing Toolbox and Machine Learning Toolbox in MATLAB, so ensure these toolboxes are installed and accessible.
To run the code, open MATLAB and navigate to the code files' directory. Execute the main.m script, which will initiate the localization process. The script will prompt you to provide the necessary input, such as the CSI dataset and other configuration parameters.
The domain adapting module is responsible for fine-tuning the localization model using the provided CSI dataset. It adapts a pre-trained model from a source domain to the target domain, allowing it to capture domain-specific information and improve localization accuracy.
The triangulation method is then applied to estimate the target's location. It utilizes the extracted CSI amplitude data from two WiFi receivers. By calculating distances from each receiver to the target location, the triangulation algorithm exploits geometric relationships among these distances to accurately estimate the real-time coordinates of the target.
To complement the localization aspect, the system incorporates a Human Activity Recognition (HAR) algorithm. This algorithm discerns and classifies the target's activities within the localized space, ensuring that the system not only determines location but also interprets ongoing activities.
The system also includes a real-time trajectory plotting feature to enhance user interaction and interpretability. This feature visually represents the movement of the tracked entity over time, providing dynamic insights into the path within the environment.
Please refer to the code documentation and comments within the files for more detailed information on specific functions, variables, and usage instructions.

The Dataset is found at the link with additional description files

https://data.mendeley.com/preview/d7442jp8b7?a=0f0eefac-efe9-4113-b3cf-88ba08400171


