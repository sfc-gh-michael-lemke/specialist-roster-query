# Specialist Roster Query

A Cortex Code skill for querying specialist/headcount roster data from Snowflake to find people by ETM Role, Territory, Market, Theater, Region, or other criteria.

## Quick Start

### Prerequisites

- [Cortex Code CLI](https://docs.snowflake.com/user-guide/snowflake-cortex/cortex-agents) installed
- Snowflake connection configured with access to the source tables (see [Data Source](#data-source))

### Installation

**Option 1: Using the install script (recommended)**
```bash
git clone https://github.com/sfc-gh-michael-lemke/specialist-roster-query.git
cd specialist-roster-query
./install.sh
```

**Option 2: Manual installation**
```bash
git clone https://github.com/sfc-gh-michael-lemke/specialist-roster-query.git
cd specialist-roster-query
mkdir -p ~/.cortex/skills/specialist-roster-query
cp SKILL.md ~/.cortex/skills/specialist-roster-query/SKILL.md
```

### Updating

```bash
cd specialist-roster-query
git pull
./install.sh
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

> **Note:** Table names include fiscal year identifiers (e.g., `FY27`). These tables are updated annually. Check the [SKILL.md](SKILL.md) for current table names and update after fiscal year transitions.

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

For the complete list of supported filter values (ETM Roles, Markets, Theaters, Regions), see [SKILL.md](SKILL.md#key-reference-values).

**Quick reference:**
- **Roles**: Product AFE, Team AFE, Industry Principal, Industry Architect, Value Engineer, Product Specialist, FinOps
- **Markets**: AMS, EMEA_Mkt, APJ_Mkt
- **Theaters**: USMajors, AMSExpansion, AMSAcquisition, USPubSec, EMEA, APJ
- **Regions**: FSI, HCLS, MFG, RCG, TMT, Federal, SLED, Commercial, and geographic regions

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

## Version

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT - See [LICENSE](LICENSE) for details.
