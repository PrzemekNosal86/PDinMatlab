# PDinMatlab
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15812076.svg)](https://doi.org/10.5281/zenodo.15812076)

> ---
> **ℹ️ Note on Repository Scope and DOI**
>
> The Cosserat-based peridynamic model will be made publicly available after the associated research results are published.  
> The current DOI points to the archived version hosted on [Zenodo](https://zenodo.org/).  
> If you are interested in updates or collaboration, feel free to get in touch.
> ---

# Title of dataset

Development of an elasto-plastic model based on Cosserat theory using the peridynamics method

---

## Contact Information

- **Principal Investigator:**  
  Dr. Eng. Przemysław Nosal  
  AGH University of Krakow  
  Email: pnosal@agh.edu.pl  
  ORCID: 0000-0001-9751-0071  

- **Data manager or custodian:**  
  Same as above.

---

## Methodology

This dataset contains MATLAB source code and simulation data related to the development and implementation of a numerical model for elasto-plastic material behavior. The model is based on the simplified Cosserat continuum theory and utilizes the peridynamics method, including both bond-based and state-based formulations.

---

## Description of methods used for collection/generation of data

The data were generated using custom MATLAB code (`elastoplasticForceState.m`) implementing the Cosserat-based peridynamic model. The simulations include both undeformed and deformed configurations of the analyzed structures. The methodology is described in the associated research proposal and will be further detailed in future publications.

- References:  
  S.A. Silling, *Reformulation of elasticity theory for discontinuities and long-range forces*, JMPS, 2000  
  P. Nosal, A. Ganczarski, *Modeling solid materials in DEM using the micropolar theory*, Adv. Struc. Mat., 2023  
  S. Riad et al., *Effect of microstructural length scales on crack propagation in elastic Cosserat media*, EFM, 2022  

---

## Methods for processing the data

All simulation variables are saved in `.mat` files to enable full reproducibility. ParaView is used for visualization of selected simulation outcomes (converted to `.vtk`, `.vts`, etc.).

---

## Instrument- or software-specific information

- MATLAB R2022b (MathWorks)
- Custom MATLAB scripts
- Toolbox used: function for line segment intersection (likely from Polyshape toolbox or `intersect` function)

---

## Standards and calibration information

Not applicable.

---

## Environmental/experimental conditions

Not applicable – all simulations are computational.

---

## Quality-assurance procedures

Validation is performed by comparing simulation outcomes with known analytical and experimental results. Numerical consistency is ensured through convergence studies and qualitative verification of physical behavior.

---

## File name structure

```
/PDinMatlab/
│
├── README.md # Documentation file
├── LICENSE # Licensing information
├── NOSB_SENS_brittle_fracture_ADR.m # Main simulation script
│
├── /material_models/ # Material behavior definitions
│ └── elasticForceStateNew.m
│
├── /solvers/ # Time integration solvers and mass matrix
│ ├── adaptiveDynamicRelaxation.m
│ └── ...
│
├── /common_files/ # Core peridynamic functions and utilities
│ ├── applyInitialCrack.m
│ └── ...
│
├── /input_output/
│ ├── /deformed_configuration/ # Plotting and visualization of results
│ │ ├── plot_scatter_damage.m
│ │ └── ...
│ └── ...
│
├── /boundary_conditions/ # Boundary condition assignment
│ ├── findSpecialBoundaryNodes.m
│ └── ...
```
---

## File formats

- **Simulation data:** `.mat`, `.txt`, `.csv`
- **Visualization:** `.vtk`, `.vts`, `.pvts`, `.jpeg`, `.tiff`, `.pdf`, `.bmp`
- **Code:** `.m`
- **Documentation:** `.tex`, `.pdf`

---

## File Naming Conventions

Saved data files follow the naming scheme:

`<base_name><description><date>verification<id>.mat`

Where:
- `<base_name>` – simulation model identifier (e.g. `NOSBPD_brittle_fracture_SENS_ADR`)
- `<description>` – user-defined simulation label (e.g. `_test_`)
- `<date>` – date of the simulation in `dd_MM_yyyy` format
- `<id>` – parameter or variant number (e.g. 1)

### Example:

`NOSBPD_brittle_fracture_SENS_ADR_test_05_07_2025_verification_1.mat`

This file stores results from a shear fracture simulation (SENS) using the NOSB peridynamics model, labeled as "test", performed on July 5, 2025, and identified as case 1.

## Column headings for tabular data

Not applicable – all variables are stored in structured `.mat` files.

---

## Versioning

A changelog section should be maintained in this README file. Each modification of the model or solver will be recorded as follows:

### Changelog

- `v1.0` (2025-04): Initial implementation of elastoplastic Cosserat-based PD model.
- `v1.1` (planned): Extension with thermal coupling and fatigue-related functionalities.

---

## Acknowledgements

The project is funded by the **MINIATURA 8** program of the **Polish National Science Centre (NCN)** under grant number **DEC-2024/08/X/ST8/00273**.  
