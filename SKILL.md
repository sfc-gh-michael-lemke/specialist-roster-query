---
name: specialist-roster-query
location: project
description: "Query specialist roster from Snowflake by ETM Role, Territory, Market, Theater, or Region. Triggers: who supports, which AFEs, list specialists, roster query, headcount query."
---

# Specialist Roster Query

Query Snowflake roster data to find specialists, AFEs, and other personnel by various criteria.

## When to Use

- User asks "who supports [territory] in [region/market]"
- User asks "which AFEs/specialists support [criteria]"
- User asks to list people by ETM Role, Territory, Market, Theater, or Region
- User asks about specialist coverage for a territory or market

## Data Source

The roster data comes from Snowflake tables:
- `IT.PIGMENT.RAW_FY27_SFDC_DEPLOYMENT_SPECIALIST_USER` - Specialist assignments
- `SALES.PLANNING.TERRITORY_HIERARCHY_FYPLANNING` - Territory hierarchy

## Base Query

Use this query as the foundation, adding WHERE clauses as needed:

```sql
WITH ranked AS (
    SELECT 
        s.D_PLANID AS PERSON_NAME,
        s.ETM_ROLE,
        s.TERRITORY_NAME,
        s.D_TERRITORY_TYPE AS TERRITORY_TYPE,
        t.MARKET_NAME,
        t.THEATER_NAME AS RAW_THEATER_NAME,
        t.REGION_NAME,
        ROW_NUMBER() OVER (PARTITION BY s.D_PLANID, s.ETM_ROLE, s.TERRITORY_NAME ORDER BY s.DS_DATE DESC) AS rn
    FROM IT.PIGMENT.RAW_FY27_SFDC_DEPLOYMENT_SPECIALIST_USER s
    LEFT JOIN SALES.PLANNING.TERRITORY_HIERARCHY_FYPLANNING t 
        ON s.TERRITORY_NAME = t.TERRITORY_NAME
    WHERE s.IS_ACTIVE = 1
)
SELECT 
    PERSON_NAME,
    ETM_ROLE,
    TERRITORY_NAME,
    TERRITORY_TYPE,
    MARKET_NAME,
    -- Derive theater from territory name suffix if no hierarchy match
    CASE 
        WHEN RAW_THEATER_NAME IS NOT NULL THEN RAW_THEATER_NAME
        WHEN TERRITORY_NAME ILIKE '%_EMEA' THEN 'EMEA'
        WHEN TERRITORY_NAME ILIKE '%_APJ' THEN 'APJ'
        WHEN TERRITORY_NAME ILIKE '%_USMajors' THEN 'USMajors'
        WHEN TERRITORY_NAME ILIKE '%_USPubSec' THEN 'USPubSec'
        WHEN TERRITORY_NAME ILIKE '%_AMSExpansion' THEN 'AMSExpansion'
        WHEN TERRITORY_NAME ILIKE '%_AMSAcquisition' THEN 'AMSAcquisition'
        WHEN MARKET_NAME = 'AMS' THEN 'AMS'
        WHEN MARKET_NAME = 'EMEA_Mkt' THEN 'EMEA'
        WHEN MARKET_NAME = 'APJ_Mkt' THEN 'APJ'
        ELSE 'AMS'
    END AS THEATER_NAME,
    -- Derive region from territory name suffix if no hierarchy match
    CASE 
        WHEN REGION_NAME IS NOT NULL THEN REGION_NAME
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_EMEA' THEN 'EMEA Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_APJ' THEN 'APJ Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_USMajors' THEN 'USMajors Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_USPubSec' THEN 'USPubSec Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_AMSExpansion' THEN 'AMSExpansion Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_AMSAcquisition' THEN 'AMSAcquisition Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_Ind' THEN 'Industries Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_Mkt' THEN 'Market Pooled'
        WHEN RAW_THEATER_NAME IS NOT NULL THEN RAW_THEATER_NAME || ' Pooled'
        ELSE 'AMS Pooled'
    END AS REGION_NAME
FROM ranked
WHERE rn = 1
ORDER BY PERSON_NAME
```

## Workflow

### Step 1: Understand the Request

Identify what the user is looking for:
- **Role type**: AFE, Product AFE, Industry Principal, Value Engineer, Product Specialist, etc.
- **Territory**: Specific territory name
- **Market**: AMS, EMEA, APJ
- **Theater**: USMajors, AMSExpansion, AMSAcquisition, USPubSec, EMEA, APJ
- **Region**: FSI, HCLS, MFG, RCG, TMT, Federal, SLED, specific expansion regions

**IMPORTANT - Manager Exclusion Rule:**
- By default, **exclude managers** when answering "who supports X" questions
- Only include managers if the user **explicitly asks** for them (e.g., "who are the managers", "include managers", "list AFE managers")
- Always add `AND ETM_ROLE NOT ILIKE '%Manager%'` unless managers are specifically requested

### Step 2: Build Query Filter

Add WHERE clauses to the base query's outer SELECT based on user criteria:

```sql
-- ALWAYS exclude managers by default (unless explicitly requested)
WHERE ETM_ROLE NOT ILIKE '%Manager%'

-- Filter by ETM Role (case-insensitive pattern match)
  AND ETM_ROLE ILIKE '%AFE%'
  AND ETM_ROLE = 'Product AFE'
  AND ETM_ROLE IN ('Product AFE', 'Team AFE')

-- Filter by Market
  AND MARKET_NAME = 'AMS'
  AND MARKET_NAME IN ('AMS', 'EMEA')

-- Filter by Theater
  AND THEATER_NAME = 'USMajors'
  AND THEATER_NAME ILIKE '%Expansion%'

-- Filter by Region
  AND REGION_NAME = 'FSI'
  AND REGION_NAME ILIKE '%Pooled%'

-- Filter by Territory
  AND TERRITORY_NAME ILIKE '%FSI%'

-- Example: AFEs in AMS (managers excluded by default)
WHERE ETM_ROLE ILIKE '%AFE%'
  AND MARKET_NAME = 'AMS'
  AND ETM_ROLE NOT ILIKE '%Manager%'

-- Example: Include managers (only when explicitly requested)
WHERE ETM_ROLE ILIKE '%AFE Manager%'
```

### Step 3: Execute Query and Format Output

Run the query via Snowflake SQL execution and present results as a markdown table.

**Example Query for AFEs in AMS (no managers):**

```sql
WITH ranked AS (
    SELECT 
        s.D_PLANID AS PERSON_NAME,
        s.ETM_ROLE,
        s.TERRITORY_NAME,
        s.D_TERRITORY_TYPE AS TERRITORY_TYPE,
        t.MARKET_NAME,
        t.THEATER_NAME AS RAW_THEATER_NAME,
        t.REGION_NAME,
        ROW_NUMBER() OVER (PARTITION BY s.D_PLANID, s.ETM_ROLE, s.TERRITORY_NAME ORDER BY s.DS_DATE DESC) AS rn
    FROM IT.PIGMENT.RAW_FY27_SFDC_DEPLOYMENT_SPECIALIST_USER s
    LEFT JOIN SALES.PLANNING.TERRITORY_HIERARCHY_FYPLANNING t 
        ON s.TERRITORY_NAME = t.TERRITORY_NAME
    WHERE s.IS_ACTIVE = 1
)
SELECT 
    PERSON_NAME,
    ETM_ROLE,
    TERRITORY_NAME,
    TERRITORY_TYPE,
    MARKET_NAME,
    CASE 
        WHEN RAW_THEATER_NAME IS NOT NULL THEN RAW_THEATER_NAME
        WHEN TERRITORY_NAME ILIKE '%_EMEA' THEN 'EMEA'
        WHEN TERRITORY_NAME ILIKE '%_APJ' THEN 'APJ'
        WHEN TERRITORY_NAME ILIKE '%_USMajors' THEN 'USMajors'
        WHEN TERRITORY_NAME ILIKE '%_USPubSec' THEN 'USPubSec'
        WHEN TERRITORY_NAME ILIKE '%_AMSExpansion' THEN 'AMSExpansion'
        WHEN TERRITORY_NAME ILIKE '%_AMSAcquisition' THEN 'AMSAcquisition'
        WHEN MARKET_NAME = 'AMS' THEN 'AMS'
        WHEN MARKET_NAME = 'EMEA_Mkt' THEN 'EMEA'
        WHEN MARKET_NAME = 'APJ_Mkt' THEN 'APJ'
        ELSE 'AMS'
    END AS THEATER_NAME,
    CASE 
        WHEN REGION_NAME IS NOT NULL THEN REGION_NAME
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_EMEA' THEN 'EMEA Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_APJ' THEN 'APJ Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_USMajors' THEN 'USMajors Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_USPubSec' THEN 'USPubSec Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_AMSExpansion' THEN 'AMSExpansion Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_AMSAcquisition' THEN 'AMSAcquisition Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_Ind' THEN 'Industries Pooled'
        WHEN RAW_THEATER_NAME IS NULL AND TERRITORY_NAME ILIKE '%_Mkt' THEN 'Market Pooled'
        WHEN RAW_THEATER_NAME IS NOT NULL THEN RAW_THEATER_NAME || ' Pooled'
        ELSE 'AMS Pooled'
    END AS REGION_NAME
FROM ranked
WHERE rn = 1
  AND ETM_ROLE ILIKE '%AFE%'
  AND MARKET_NAME = 'AMS'
  AND ETM_ROLE NOT ILIKE '%Manager%'
ORDER BY PERSON_NAME
```

## Key Reference Values

### ETM Role Values
- `Product AFE` - Product Applied Field Engineer
- `Product AFE Manager` - Product AFE Manager
- `Team AFE` - Team AFE
- `Industry Principal` - Industry Principal
- `Industry Principal Manager` - Industry Principal Manager
- `Team Industry Principal` - Team Industry Principal
- `Industry Architect` - Industry Architect
- `Industry Architect Manager` - Industry Architect Manager
- `Team Industry Architect` - Team Industry Architect Manager
- `Value Engineer` - Value Engineer
- `Product Specialist` - Product Specialist
- `Product Specialist Manager` - Product Specialist Manager
- `Territory Visibility` - Territory visibility assignment
- `FinOps` - FinOps role

### Territory Type Values
- `Market` - Market-level territory
- `Theater` - Theater-level territory
- `Region` - Region-level territory
- `Patch` - Patch-level territory (usually industry-specific)
- `District` - District-level territory
- `Global` - Global territory

### Market Values
- `AMS` - Americas
- `EMEA_Mkt` - Europe/Middle East/Africa (in MARKET_NAME)
- `APJ_Mkt` - Asia Pacific Japan (in MARKET_NAME)

### Theater Values
- `USMajors` - US Major accounts
- `AMSExpansion` - Americas Expansion
- `AMSAcquisition` - Americas Acquisition
- `USPubSec` - US Public Sector
- `EMEA` - Europe/Middle East/Africa
- `APJ` - Asia Pacific Japan
- `AMS Pooled` - AMS Pooled (default when no theater match)

### Region Values
- `FSI`, `FSIGlobals` - Financial Services
- `HCLS` - Healthcare & Life Sciences
- `MFG` - Manufacturing
- `RCG` - Retail & Consumer Goods
- `TMT` - Technology, Media, Telecom
- `Federal`, `SLED` - Government
- `Commercial` - Commercial segment
- `ANZ` - Australia/New Zealand
- Geographic expansion regions: `NortheastExp`, `SoutheastExp`, `SouthwestExp`, `NorthwestExp`, `CentralExp`, `USGrowthExp`, `CanadaExp`
- `LATAM` - Latin America
- `UK`, `META`, `SouthEMEA`, `EMEACommercial` - EMEA regions
- Various `*Pooled` designations for pooled coverage

## Output Format

Present results as a markdown table with:
1. **Count of unique people** (not rows) - use `COUNT(DISTINCT PERSON_NAME)` since one person can have multiple territory assignments
2. Table with relevant columns (Person Name, ETM Role, Territory, Theater, Region)
3. Summary by key groupings if relevant

**IMPORTANT**: Always count unique people, not total rows. One person can have multiple territory assignments, so row count will be higher than actual headcount.

**Example Output:**
```
## Product AFEs Supporting AMS (No Managers): 15 unique people

| Person Name | ETM Role | Territories |
|-------------|----------|-------------|
| Adam Timm (18131) | Product AFE | CommAcqWest, USGrowthExp, CanadaExp |
| Marc Henderson (3959) | Product AFE | RCG, MFG |
...

**Summary by Theater:**
- **8 people** in AMSExpansion
- **5 people** in AMSAcquisition
- **2 people** in USMajors
```

**Query to get unique counts:**
```sql
-- Count unique people by role
SELECT ETM_ROLE, COUNT(DISTINCT PERSON_NAME) as HEADCOUNT
FROM (<base_query>)
GROUP BY ETM_ROLE
ORDER BY HEADCOUNT DESC
```

## Common Query Patterns

**Note:** All patterns below assume managers are excluded by default. Add `AND ETM_ROLE NOT ILIKE '%Manager%'` to every query.

### "Who supports FSI"
Add: `WHERE (REGION_NAME = 'FSI' OR TERRITORY_NAME ILIKE '%FSI%') AND ETM_ROLE NOT ILIKE '%Manager%'`

### "Which Product AFEs support USMajors"
Add: `WHERE ETM_ROLE = 'Product AFE' AND THEATER_NAME = 'USMajors'`
(No manager filter needed - Product AFE is not a manager role)

### "List Industry Principals in EMEA"
Add: `WHERE ETM_ROLE = 'Industry Principal' AND THEATER_NAME = 'EMEA'`
(Use exact match to exclude Industry Principal Manager)

### "Who supports Healthcare"
Add: `WHERE (TERRITORY_NAME ILIKE '%Healthcare%' OR TERRITORY_NAME ILIKE '%HCLS%' OR REGION_NAME = 'HCLS') AND ETM_ROLE NOT ILIKE '%Manager%'`

### "AFEs in AMS Pooled"
Add: `WHERE ETM_ROLE ILIKE '%AFE%' AND ETM_ROLE NOT ILIKE '%Manager%' AND REGION_NAME = 'AMS Pooled'`

### "Who are the AFE managers" (managers explicitly requested)
Add: `WHERE ETM_ROLE ILIKE '%AFE Manager%'`

## Error Handling

Handle these common scenarios gracefully:

### No Results Found
If the query returns zero rows:
- Confirm the filter criteria with the user
- Suggest broadening the search (e.g., remove region filter, use ILIKE patterns)
- Check for typos in filter values

### Table Access Errors
If you receive permission or object-not-found errors:
- Inform the user they need SELECT access to both source tables
- Suggest checking their Snowflake connection configuration

### Invalid Filter Values
If the user provides an unrecognized filter value:
- Show them the valid options from the Key Reference Values section
- Suggest the closest matching value if possible

### Ambiguous Requests
If the user's request is unclear:
- Ask clarifying questions before running queries
- Example: "Do you want all AFE roles (Product AFE + Team AFE) or just Product AFEs?"

## Notes

- The query uses ROW_NUMBER to deduplicate by taking the most recent record (by DS_DATE) for each person-role-territory combination
- `IS_ACTIVE = 1` filters to only active assignments
- **Industry patch territories** (e.g., `MediaEnt_EMEA`, `FinalServ_APJ`, `HealthcareLS_USMajors`) don't exist in the territory hierarchy table, so the query parses the suffix (`_EMEA`, `_APJ`, `_USMajors`, etc.) to derive the correct theater
- The CASE statements derive THEATER_NAME and REGION_NAME from territory name suffixes when no hierarchy match is found
- **One person can have multiple rows due to multiple territory assignments** - always count unique PERSON_NAME for headcount
- **Exclude managers by default** - only include managers when explicitly requested
- Use ILIKE for case-insensitive pattern matching in Snowflake
