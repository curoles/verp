VERP - Verilog ERB Pre-Processor
================================

VERP purpose is to simplify and automate Verilog coding,
similar to Verilog EP3 and RobustVerilog pre-processing tools.
VERP takes text with Verilog code and Embedded Ruby code and
process it all into Verilog code.

# File name conventions

VERP expects file name to be:
* `*.v.erb` - for Verilog or
* `*.sv.erb` - for SystemVerilog

# Usage
## Standalone executable

## Use as library

```ruby
require_relative 'Verp'
```
