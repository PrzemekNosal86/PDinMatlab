# PDinMatlab

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

- _NOSBPD_Nosal_ <br />
  - _boundary_conditions_ – input data for boundary definitions <br />
  - _common_files_ – shared functions and scripts <br />
  - _figures_ – exported figures (plots, animations, visuals) <br />
  - _input_output_ <br />
    - _undeformed_configuration_ – input geometry and settings <br />
    - _deformed_configuration_ – results of deformation <br />
  - _material_models_ – material law definitions (e.g. elastoplasticForceState.m) <br />
  - _results_ – simulation output (.mat) <br />
  - _solvers_ – main simulation drivers and core functions <br />

---

### Good Practice

- **Structure template:** `<category>_<property>_<variant>.mat`
- **Attributes:** Time step, configuration type, material model
- **Codes/abbreviations:**  
  - `init` – initial state  
  - `def` – deformed state  
  - `EP` – elastoplastic  
  - `BB` – bond-based  
  - `SB` – state-based  

**Examples:**
- `geometry_init_BB.mat`
- `results_def_EP_SB.mat`
- `stress_map_T5_BB.vtk`

---

## File formats

- **Simulation data:** `.mat`, `.txt`, `.csv`
- **Visualization:** `.vtk`, `.vts`, `.pvts`, `.jpeg`, `.tiff`, `.pdf`, `.bmp`
- **Code:** `.m`
- **Documentation:** `.tex`, `.pdf`

---

## Column headings for tabular data

Not applicable – all variables are stored in structured `.mat` files.

---

## Versioning

A changelog section should be maintained in this README file. Each modification of the model or solver will be recorded as follows:

### Changelog

- `v1.0` (2025-04): Initial implementation of elastoplastic Cosserat-based PD model.
- `v1.1` (planned): Extension with thermal coupling and fatigue-related functionalities.

---

*Please remove the "Good Practice" hints and notes when finalizing this document.*
