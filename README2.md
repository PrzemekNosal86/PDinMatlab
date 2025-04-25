# Dataset: Elastoplastic Peridynamic Simulations Based on Cosserat Theory

## Introduction

This dataset contains numerical results obtained as part of the project *"Development of an Elastoplastic Model Based on Cosserat Theory Using the Peridynamics Method"*. The aim of the project is to analyze strain and damage localization phenomena in materials prone to shear. The data can be used for validation of numerical models, comparative studies, and research into failure propagation mechanisms.

The project is funded by the **MINIATURA 8** program of the **Polish National Science Centre (NCN)**. For more context, see the related publication: [link or DOI, if available].

## Basic Requirements

The dataset is stored in `.mat` format and can be opened with MATLAB R2022b or later. Data visualization and post-processing may be performed using **ParaView** and **Python 3.9+**.

## Folder Structure

```
/cosserat_peridynamics_data/
│
├── README.md                     # Documentation file
├── LICENSE                       # Licensing information
├── /raw_data/                    # Unprocessed simulation results
│   ├── config1.mat
│   ├── config2.mat
│   └── ...
├── /processed_data/              # Preprocessed and normalized data
│   ├── stress_fields.mat
│   └── strain_localization.mat
├── /scripts/                     # MATLAB scripts for analysis and export
│   ├── visualize_damage.m
│   └── export_to_vtk.m
```

## File Naming Conventions

Files follow the naming scheme:  
`<data_type>_<config_id>.mat`

Example:  
`stress_field_config1.mat` – stress field for configuration #1.

## File Formats

- `.mat` – MATLAB data (arrays, structures)
- `.vtk` – spatial data compatible with ParaView
- `.m` – MATLAB scripts

## Data Collection (Optional)

Data was generated using custom MATLAB simulations based on a peridynamic model extended with Cosserat theory. Mesh resolution was kept constant across all configurations. Material behavior was simulated with an elastoplastic constitutive law. Parameters were selected to study shear-induced localization. No real-world measurements were included, and no ethical approval was required.

## Codebook

| Variable        | Description                                           | Data Type        |
|----------------|-------------------------------------------------------|------------------|
| `GRID`          | Node matrix: `[node ID, x, y]`                        | Numeric array    |
| `INIBOND`       | Connectivity list: `[source node, family nodes]`     | Numeric array    |
| `Damage`        | Damage parameter for each node                       | Numeric vector   |
| `StressTensor`  | Cauchy stress tensors at each node                   | Structure        |
| `StrainTensor`  | Strain tensors (possibly reduced)                    | Structure        |

## License

This dataset is released under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). You are free to use, share, and adapt the data, provided that appropriate credit is given.

## Citation (Optional)

If you use this dataset in your research, please cite:

> [Author(s)], *Elastoplastic Peridynamic Simulations Based on Cosserat Theory*, NCN MINIATURA 8, 2025. DOI: [insert DOI if available].

## Contact

For questions or feedback, please contact:

**Dr. Eng. [Your Name]**  
AGH University of Krakow, Faculty of [Your Faculty]  
📧 [your.email@agh.edu.pl]
