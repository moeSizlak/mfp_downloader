# mfp_downloader

mfp_downloader is a Ruby script for connecting to the undocumented MyFitnessPal API, plundering some data and whatnot, and creating a [csv](./food_data.csv) that contains a daily sum of each nutrient

## Installation

Just change your username and password inside the .rb file

## Usage

Usage: mfp.rb <from_date> [thru_date]  
Dates must be in the form YYYY-MM-DD.  [thru_date] is optional, and if omitted will be set to the same as <from_date>  

```bash
ruby mfp.rb 2018-08-08 2018-08-31
```

