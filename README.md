![Logo](nmrprocflow_logo.png)
# nmrprocflow

Version: 1.2.6

## Short description

An efficient GUI tool for spectra processing from 1D NMR metabolomics data.

## Description

The NMRProcFlow open source software provides a complete set of tools for processing and visualization of 1D NMR data, the whole within an interactive interface based on a spectra visualization

## Key features

The NMRProcFlow open source software provides an efficient GUI tool for spectra processing from 1D NMR metabolomics data, based on an interactive interface for the spectra visualization, that greatly helps spectra processing.

The 'NMR spectra viewer' is the central tool of NMRProcFlow and the core of the application. It allows the user to visually explore the spectra overlaid or stacked, to zoom on intensity scale, to group set of spectra by color based on their factor level.

NMRProcFlow was built by involving NMR spectroscopists eager to have a quick and easy tool to use.

the spectra processing includes: the calibration of the ppm scale, the base line correction (locally or fully), the realignment of a set of ppm areas, and the binning (Intelligent, variable size or fixed width)

## Tool Authors 
- Daniel Jacobs

## Container Contributors
- [Kristian Peters](https://github.com/korseby) (IPB-Halle)
- [Pabo Moreno](https://github.com/pcm32) (EMBL-EBI)

## Website

- http://www.nmrprocflow.org

## Git Repository

- https://bitbucket.org/nmrprocflow/nmrproc

## Installation 

For local individual installation:

```bash
docker pull container-registry.phenomenal-h2020.eu/phnmnl/nmrprocflow
```

## Usage Instructions

For direct docker usage:

```bash
docker run container-registry.phenomenal-h2020.eu/phnmnl/nmrprocflow ...
```

## Publications

- Jacob, D., Deborde, C., Lefebvre, M., Maucourt, M. and Moing, A. (2017) NMRProcFlow: A graphical and interactive tool dedicated to 1D spectra processing for NMR-based metabolomics, Metabolomics 13:36. doi:10.1007/s11306-017-1178-y
