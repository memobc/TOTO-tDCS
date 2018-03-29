# TOTO-tDCS

This is the repository home of the TOTO-tDCS experiment, including both stimulus presentation and data analysis scripts.  

## Stimulus Presentation

The Stimulus presentation scripts include:  

`total_recall.m` = main stimulus presentation script. Calls all scripts below.  
`recall.m` = presents word lists and records participant's free recall.  
`functions/init_psychtoolbox.m` = function for initializing [psychtoolbox](http://psychtoolbox.org/) functions.  
`functions/generate_lists.m` = function for generating study lists for each participant.  
`functions/instructions_screen.m` = function for displaying a [psychtoolbox](http://psychtoolbox.org/) instructions screen.  
`functions/record_responses.m` = function for recording keyboard responses from the [psychtoolbox](http://psychtoolbox.org/)'s `KbQueue`  

## Data Analysis

Data analysis scripts include:

`toto-tdcs.ipynb` = main data analysis using [Quail](http://cdl-quail.readthedocs.io/en/latest/).  
`total-recall.md` = markdown of results from pilots.  
`total-recall.Rmd` = R markdown used to generate `total-recall.md`.  
`total-recall.ipynb` = [jupyter](http://jupyter.org/) notebook analyzing pilot data.  

## Stimuli

Stimuli consist of normed words from [Long, Danoff, & Kahana 2015](https://doi.org/10.3758/s13423-014-0791-2)<sup>1</sup>.  


## References

<sup>1</sup> Long, N.M., Danoff, M.S. & Kahana, M.J. Psychon Bull Rev (2015) 22: 1328. https://doi.org/10.3758/s13423-014-0791-2  
