# Specialist Roster Query

A Cortex Code skill for querying specialist/headcount roster data from Snowflake to find people by ETM Role, Territory, Market, Theater, Region, or other criteria.

## Installation

Copy `SKILL.md` to your Cortex Code skills directory:

```bash
cp SKILL.md ~/.cortex/skills/specialist-roster-query/SKILL.md
```

## Usage

The skill auto-triggers when you ask questions like:
- "which AFEs support FSI"
- "who supports Healthcare in USMajors"
- "list Industry Principals in EMEA"
- "which Product Specialists are in APJ"

Or invoke directly with `/specialist-roster-query`.

## Data Source

Queries Snowflake tables:
- `IT.PIGMENT.RAW_FY27_SFDC_DEPLOYMENT_SPECIALIST_USER` - Specialist assignments
- `SALES.PLANNING.TERRITORY_HIERARCHY_FYPLANNING` - Territory hierarchy

## Features

- Queries live Snowflake data for up-to-date roster information
- Filters by ETM Role, Territory, Market, Theater, Region
- Deduplicates assignments using most recent record per person-role-territory
- **Counts unique people (headcount), not rows** - one person can have multiple territory assignments
- Excludes managers when requested
- Outputs formatted markdown tables with counts and summaries

## Supported Filter Values

### ETM Role
- `Product AFE`, `Product AFE Manager`, `Team AFE`
- `Industry Principal`, `Industry Principal Manager`, `Team Industry Principal`
- `Industry Architect`, `Industry Architect Manager`, `Team Industry Architect`
- `Value Engineer`
- `Product Specialist`, `Product Specialist Manager`
- `Territory Visibility`, `FinOps`

### Market
- `AMS` - Americas
- `EMEA_Mkt` - Europe/Middle East/Africa
- `APJ_Mkt` - Asia Pacific Japan

### Theater
- `USMajors`, `AMSExpansion`, `AMSAcquisition`, `USPubSec`
- `EMEA`, `APJ`
- `AMS Pooled` (default)

### Region
- `FSI`, `FSIGlobals`, `HCLS`, `MFG`, `RCG`, `TMT`
- `Federal`, `SLED`, `Commercial`
- `NortheastExp`, `SoutheastExp`, `SouthwestExp`, `NorthwestExp`, `CentralExp`, `USGrowthExp`, `CanadaExp`
- `LATAM`, `ANZ`, `UK`, `META`, `SouthEMEA`, `EMEACommercial`
- Various `*Pooled` designations

## License

MIT
