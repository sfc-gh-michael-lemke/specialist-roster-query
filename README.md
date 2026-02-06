# Specialist Roster Query

A Cortex Code skill for querying specialist/headcount roster data from Snowflake to find people by ETM Role, Territory, Market, Theater, Region, or other criteria.

## Quick Start

### Prerequisites

- [Cortex Code CLI](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-agents) installed
- Snowflake connection configured with access to:
  - `IT.PIGMENT.RAW_FY27_SFDC_DEPLOYMENT_SPECIALIST_USER`
  - `SALES.PLANNING.TERRITORY_HIERARCHY_FYPLANNING`

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sfc-gh-michael-lemke/specialist-roster-query.git
   cd specialist-roster-query
   ```

2. **Create the skills directory (if it doesn't exist):**
   ```bash
   mkdir -p ~/.cortex/skills/specialist-roster-query
   ```

3. **Copy the skill file:**
   ```bash
   cp SKILL.md ~/.cortex/skills/specialist-roster-query/SKILL.md
   ```

4. **Verify installation:**
   ```bash
   ls ~/.cortex/skills/specialist-roster-query/
   # Should show: SKILL.md
   ```

5. **Start using it:**
   Open Cortex Code and ask a question like "who supports USMajors"

### Updating

To get the latest version:
```bash
cd specialist-roster-query
git pull
cp SKILL.md ~/.cortex/skills/specialist-roster-query/SKILL.md
```

## Usage

The skill auto-triggers when you ask questions like:
- "who supports USMajors"
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
- **Excludes managers by default** - only includes managers when explicitly requested (e.g., "who are the AFE managers")
- Parses industry territory suffixes (e.g., `MediaEnt_EMEA`, `FinalServ_APJ`) to derive correct theater
- Outputs formatted markdown tables with counts and summaries

## Supported Filter Values

### ETM Role (Individual Contributors)
- `Product AFE` - Product Applied Field Engineer
- `Team AFE` - Team AFE
- `Industry Principal` - Industry Principal
- `Industry Architect` - Industry Architect
- `Value Engineer` - Value Engineer
- `Product Specialist` - Product Specialist
- `FinOps` - FinOps

### ETM Role (Managers - only when explicitly requested)
- `Product AFE Manager`
- `Industry Principal Manager`
- `Industry Architect Manager`
- `Product Specialist Manager`

### Market
- `AMS` - Americas
- `EMEA_Mkt` - Europe/Middle East/Africa
- `APJ_Mkt` - Asia Pacific Japan

### Theater
- `USMajors` - US Major accounts
- `AMSExpansion` - Americas Expansion
- `AMSAcquisition` - Americas Acquisition
- `USPubSec` - US Public Sector
- `EMEA` - Europe/Middle East/Africa
- `APJ` - Asia Pacific Japan
- `AMS` - Americas (pooled)

### Region
- `FSI`, `FSIGlobals` - Financial Services
- `HCLS` - Healthcare & Life Sciences
- `MFG` - Manufacturing
- `RCG` - Retail & Consumer Goods
- `TMT` - Technology, Media, Telecom
- `Federal`, `SLED` - Government
- `Commercial` - Commercial segment
- Geographic: `NortheastExp`, `SoutheastExp`, `SouthwestExp`, `NorthwestExp`, `CentralExp`, `USGrowthExp`, `CanadaExp`, `LATAM`, `ANZ`, `UK`, `META`, `SouthEMEA`, `EMEACommercial`
- Various `*Pooled` designations for pooled coverage

## Example Queries

| Question | What it returns |
|----------|-----------------|
| "who supports USMajors" | All specialists assigned to USMajors (no managers) |
| "who supports USMajors or AMS pooled" | Specialists in USMajors regions + AMS pooled |
| "which Product AFEs support FSI" | Product AFEs assigned to FSI region |
| "list Industry Principals in EMEA" | Industry Principals in EMEA theater |
| "who are the AFE managers" | AFE managers (managers explicitly requested) |

## Troubleshooting

### Skill not triggering
- Verify the skill file is in the correct location: `~/.cortex/skills/specialist-roster-query/SKILL.md`
- Restart Cortex Code after installing

### Query errors
- Ensure your Snowflake connection has SELECT access to both source tables
- Check that your connection is set correctly in Cortex Code

### Unexpected results
- The skill excludes managers by default - explicitly ask for managers if needed
- One person can appear multiple times if they have multiple territory assignments

## License

MIT
