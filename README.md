# bd-pw-project
Repository for my final project on Big Data postgraduate studies at Warsaw University of Technoloogy

## Project structure
```text
.
├── archive               # Archived unused files
    └── PoC               # Directory with dropped analysis of Warsaw trams and buses (R Package)
├── thesis                # Placeholder for thesis documents and other files
    └── figures           # Images and python scripts used to generate figures used in the thesis
└── README.md             # Project summary
```

## Usage

Thesis is written in Rmarkdown language. To render it to .pdf, `knit` the `thesis/thesis_main.Rmd` file.

Update `miniconda_path` and `miniconda_env_name` document parameters accordingly

## Requirements

- installed R and RStudio, `reticulate` and `fs` packages
- miniconda with python venv with `diagrams` package
