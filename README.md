# METAR Report Processor

This project processes METAR (Meteorological Terminal Air Report) data, parsing reports and maintaining statistics on wind speeds for various airports.

[Requirements](docs/requirements.md)

[Assumptions and Implementation details](docs/assumptions_and_implementation_details.md)

[Classes docs](doc/index.html)

## Testing
```bash
rspec spec
.......................

Finished in 0.04056 seconds (files took 0.58722 seconds to load)
23 examples, 0 failures
```

## Classes

- `MetarParserService`: Parses raw METAR report strings.
- `MetarReportRepository`: Stores and manages METAR report data.
- `MetarStreamProcessor`: Processes streams of METAR reports.
- `MetarStreamService`: Provides a high-level interface for processing reports and retrieving stats.

## Basic Usage

### Generating Sample METAR Reports

To generate a sample set of METAR reports, use the following rake task:

```bash
rake metar:generate_reports[10000] > metar_reports.txt
```

This will generate 10,000 sample METAR reports and save them to `metar_reports.txt`.

### Processing METAR Reports

To process the generated METAR reports, use:

```bash
rake metar:process_reports
```

By default, this will process the reports from `metar_reports.txt`. If you want to use a different file, you can specify it:

```bash
rake metar:process_reports[custom_reports.txt]
```

### Retrieving Statistics

After processing the reports, you can retrieve statistics using the Rails console:

```bash
rails console
```

Then, in the console:

```ruby
service = MetarStreamService.new
service.process_file('metar_reports.txt')
stats = service.get_stats
puts stats
```
This will display the average and current wind speeds for each airport in the processed reports.
This will process the reports from metar_reports.txt and then display the statistics.
This approach allows the `MetarStreamService` to work with files while maintaining its ability to process individual reports. The `process_file` method reads the file line by line, which is memory-efficient for large files.

### Running the Entire Process
To generate reports, process them, and see the results all at once, you can use:
```bash
rake metar:generate_reports[10000] > metar_reports.txt && rails runner "service = MetarStreamService.new; service.process_file('metar_reports.txt'); puts service.get_stats"
```

This one-liner does the following:

Generates 100,000 METAR reports and saves them to metar_reports.txt.
Uses rails runner to execute Ruby code in the context of our Rails application.
Creates a new MetarStreamService.
Processes the metar_reports.txt file.
Outputs the statistics.

This approach combines the report generation and processing into a single command, making it easier to run the entire workflow at once. It also directly uses the MetarStreamService to process the file and retrieve stats, which is more in line with how we've structured our service.

# With benchmarking
```bash
rake metar:generate_reports[10000] > metar_reports.txt && rails runner "require 'benchmark'; time = Benchmark.measure { service = MetarStreamService.new; service.process_file('metar_reports.txt'); puts service.get_stats }; puts \"\nExecution time: #{time.real.round(2)} seconds\""
```
Execution time: `0.22 seconds`

