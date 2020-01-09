# mfp_downloader

mfp_downloader is a Ruby script for connecting to the undocumented MyFitnessPal API, plundering some data and whatnot, and creating a [csv](./food_data.csv) that contains a daily sum of each nutrient

## Requirements

The following Ruby gems are required:
* json
* time
* nokogiri
* faraday
* faraday_middleware
* faraday-cookie_jar
* faraday/detailed_logger
* csv

As of this writing, faraday-detailed_logger is not compatible with faraday-1.0.0, so I recommend using faraday-0.17.3:

You can install them all with this command:
```bash
gem install faraday -v 0.17.3
gem install faraday_middleware faraday-cookie_jar faraday-detailed_logger nokogiri csv json

```



## Installation

Just change your username and password inside the .rb file

## Usage

Usage: mfp.rb <from_date> [thru_date]  
Dates must be in the form YYYY-MM-DD.  [thru_date] is optional, and if omitted will be set to the same as <from_date>  

```bash
ruby mfp.rb 2018-08-08 2018-08-31
```

