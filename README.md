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



#Executive Summary 









