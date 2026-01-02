# Validation of Video-Derived Wave Height at the Port of Sines, Portugal


## Project Background

This work is part of the ongoing **NEXUS Agenda** project, which focuses on the digital transition and decarbonisation of the Port of Sines, Portugal (NEXUS Agenda, 2023). A key requirement to support these objectives is the accurate estimation of local wave parameters—namely wave height, period, and direction—which are essential for informed decision-making in coastal and harbour operations and management.

Due to the deep bathymetry at the Port of Sines, the installation of hydrodynamic sensors in the nearshore zone is not feasible. As a result, there is a clear need for a cost-effective and reliable alternative to in situ measurements. To address this challenge, a methodology based on UAV imagery was developed to estimate significant wave height (Hs_vid). This approach was validated using ADCP measurements at Figueira da Foz, which served as the reference site. The methodology was subsequently applied at the Port of Sines, where the estimated wave heights were compared with wave model outputs under different sea-state conditions (Hs_M1 to Hs_M2).

Insights and recommendations are presented across three key aspects:

* **Method reliability**: Evaluation of the consistency between video-derived and model-based significant wave heights, identification of detected sea states, and assessment of overall discrepancies.
* **Environmental influence**: Analysis of the effects of environmental factors, such as wind speed, on the estimated wave parameters.
* **Suitability of method application**: Assessment of historical trends to identify periods most suitable for the application of the proposed methodology.

An interactive Power BI dashboard can be downloaded (here)  
SQL queries to clean, organise, and prepare data for the dashboard can be found (here)  
Targeted DAX queries regarding research or business questions can be found (here)  


##  Datasets 
**Video:** 615 video 10-minute datasets were obtained on March 2025 from the installed fixed camera at the Port os Sines, each frame was recorded at 30 frames per second making it a total of 2,880,000 processed frames, wave features are extracted and estimated from each frame following the method (see papers), Hs_vid is then calcuated from each each extracted frame for each video footage and converted into a structured dataset, see Matlab script (here) 

**Wave model data and wind speed:** SIMAR-44 wave simulation data from Puertos del Estado (AEMET, www.aemet.es) were used, providing hourly wave height and wind speed from 1 January 2024 to 31 March 2025. Historical wind speed data from 2015–2024 were also included to support long-term analysis.  



# Executive Summary 
Hs_vid exhibits a consistent pattern across all Hs_M cases, indicating that the methodology effectively captures shoaling wave characteristics. The small discrepancies in the trend result from wave transformations between offshore and nearshore conditions, which are expected due to bathymetric changes and shoaling processes, particularly as the model station is located approximately 10 km offshore from the study area. The weakest agreement is observed between Hs_vid and Hs_M3. In contrast, Hs_vid shows better agreement with Hs_1 and Hs_M2, with mean absolute percentage errors (MAPE) of 33% and 32%, respectively, which fall within a reasonable accuracy range for nearshore wave model performance.



![Wave Height Validation](Hs_M.jpg)
*Video-derived vs. model-predicted significant wave heights showing R² = 0.94 and 97.5% agreement (Bias = 0.03m, RMSE = 0.17m)*


Wind speed exhibits a more consistent pattern for Hs_vid, with an R² value of 0.3, indicating that wind-driven wave generation explains approximately 30% of the variance in wave height. Other contributing factors may include wave model accuracy, wave transformations during shoaling, bathymetric effects, and swell propagation from distant sources.
Notably, discrepancies in Hs_vid increase when wind speed exceeds 7 m/s, which can be attributed to two primary factors: (1) whitecap formation during rough sea states, and (2) camera shake induced by strong winds. Since the methodology measures the inverted shadow characteristics of wave features, any high-intensity features (e.g., breaking waves or whitecaps) within the measurement area result in inaccurate estimation. Additionally, camera shake degrades feature detection accuracy, further compromising measurement quality under high wind conditions.  

![Kpi](KPI_Vel.jpg)

Therefore, identifying optimal deployment conditions and measurement windows is critical for operational efficiency and cost-effectiveness. Analysis of historical wind speed data below 7 m/s between 2015 and 2024 reveals that the method achieves exceptional year-round operational availability, exceeding 70% for most years. Even during the least favorable conditions in 2016 and 2019, operational availability remained at 65%, translating to approximately 237 days per year of viable measurement conditions. This high temporal availability (65-75% annually) enables continuous coastal monitoring at significantly lower costs compared to traditional in-situ sensors, which require permanent installation and ongoing maintenance. The methodology's reliable operational window makes it suitable for commercial applications in port operations, coastal infrastructure monitoring, and maritime safety assessments, where wave data is essential for decision-making but budget constraints limit permanent sensor installations. Additionally, the UAV-based approach offers operational flexibility—deployments can be scheduled during optimal weather windows, avoiding equipment damage during extreme conditions while maintaining sufficient data coverage for seasonal trend analysis and engineering design parameters.


![Vel](Vel_his.jpg)
