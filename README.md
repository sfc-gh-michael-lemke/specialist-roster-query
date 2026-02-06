# Specialist Roster Query

A Cortex Code skill for querying specialist/headcount roster Excel files to find people by F3 Function, Workload, Sales Scope, Sales Region, or other criteria.

## Installation

Copy `SKILL.md` to your Cortex Code skills directory:

```bash
cp SKILL.md ~/.cortex/skills/specialist-roster-query/SKILL.md
```

## Usage

The skill auto-triggers when you ask questions like:
- "which AFEs support AI/ML in AMS"
- "who supports Data Engineering in USMajors"
- "list specialists in EMEA"

Or invoke directly with `/specialist-roster-query`.

## Features

- Queries Excel roster files (`.xlsx`) using pandas
- Filters by F3 Function, Workload, Sales Scope, Sales Region
- Handles column name variations between file versions
- Shows open positions with clean "Open Position" label
- Excludes managers when requested
- Outputs formatted markdown tables with counts and summaries

## Supported Filter Values

### F3 Function
- `AFE` - Applied Field Engineer
- `AFE Mgmt` - AFE Manager
- `Field CTO`, `Field CTO Mgmt`
- `Data Cloud Specialist`
- `AI Specialist`, `Solution Innovation`

### Workload
- `AI/ML`, `ML`, `Data Engineering`, `OLTP`, `Analytics`, `Apps & Collab`

### Sales Scope (Market or Theater)
- `AMS`, `USMajors`, `AMSExpansion`, `AMSAcquisition`, `USPubSec`, `EMEA`, `APJ`

### Sales Region
- `Pooled`, `FSI`, `FSIGlobals`, `HCLS`, `MFG`, `RCG`, `TMT`, `Federal`, `SLED`, `LATAM`, etc.

## License

MIT
