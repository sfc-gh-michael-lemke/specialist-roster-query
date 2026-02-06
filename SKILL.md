---
name: specialist-roster-query
description: "Query specialist/headcount roster Excel files to find people by F3 Function, Workload, Sales Scope, Sales Region, or other criteria. Use for: finding AFEs, specialists, Field CTOs by workload or region, listing who supports specific markets (AMS, USMajors, EMEA, APJ), filtering by role criteria. Triggers: who supports, which AFEs, list specialists, roster query, headcount query, find people in."
---

# Specialist Roster Query

Query Excel roster files to find specialists, AFEs, and other personnel by various criteria.

## When to Use

- User asks "who supports [workload] in [region/scope]"
- User asks "which AFEs/specialists support [criteria]"
- User asks to list people by F3 Function, Workload, Sales Scope, or Sales Region
- User provides an Excel file path and asks to filter/query personnel data

## Workflow

### Step 1: Identify File and Columns

**Actions:**

1. **Read** the Excel file to check available columns:
```python
import pandas as pd
df = pd.read_excel('<FILE_PATH>')
print(df.columns.tolist())
```

2. **Identify** key columns (names may vary between files):
   - Name column: `Name`
   - ID column: `EEID`
   - Function: `F3 Function` (values: AFE, AFE Mgmt, Field CTO, etc.)
   - Workload: `Workload` (values: AI/ML, ML, Data Engineering, OLTP, Analytics, Apps & Collab, etc.)
   - Scope: `Sales Scope - Market or Theater` OR `Market or Theater` (values: AMS, USMajors, EMEA, APJ, AMSExpansion, etc.)
   - Region: `Sales Region` (values: Pooled, FSI, HCLS, MFG, RCG, TMT, etc.)
   - Derived: `Sales Scope` (combination of scope + region, e.g., "AMS - Pooled", "USMajors - RCG")

### Step 2: Build Query Filter

**Common Filter Patterns:**

```python
# Filter by F3 Function (exclude managers if requested)
df[df['F3 Function'] == 'AFE']  # AFE only, no managers
df[df['F3 Function'].str.contains('AFE', case=False, na=False)]  # AFE and AFE Mgmt

# Filter by Workload
df[df['Workload'].str.contains('AI|ML', case=False, na=False)]  # AI/ML or ML
df[df['Workload'].str.contains('Data Engineering', case=False, na=False)]

# Filter by Sales Scope (Market or Theater)
df[df['<SCOPE_COLUMN>'] == 'AMS']
df[df['<SCOPE_COLUMN>'].isin(['AMS', 'USMajors'])]

# Filter by Sales Region
df[df['Sales Region'] == 'Pooled']
df[df['Sales Region'].isin(['RCG', 'FSI', 'HCLS'])]

# Combined: Scope + Region (e.g., "USMajors - RCG" or "AMS Pooled")
df[
    ((df['<SCOPE_COLUMN>'] == 'USMajors') & (df['Sales Region'] == 'RCG')) |
    ((df['<SCOPE_COLUMN>'] == 'AMS') & (df['Sales Region'] == 'Pooled'))
]

# Exclude empty/invalid entries
df[df['EEID'].notna()]
```

### Step 3: Execute Query and Format Output

**Standard Query Template:**

```python
import pandas as pd

df = pd.read_excel('<FILE_PATH>')

# Determine correct column names
scope_col = 'Sales Scope - Market or Theater' if 'Sales Scope - Market or Theater' in df.columns else 'Market or Theater'

# Apply filters based on user criteria
filtered = df[
    (df['F3 Function'] == 'AFE') &  # Adjust based on request
    (df['Workload'].str.contains('<WORKLOAD_PATTERN>', case=False, na=False)) &
    (df['EEID'].notna()) &
    (
        # Scope/Region conditions
        ((df[scope_col] == '<SCOPE1>') & (df['Sales Region'] == '<REGION1>')) |
        ((df[scope_col] == '<SCOPE2>') & (df['Sales Region'] == '<REGION2>'))
    )
].copy()

# Clean name (remove EEID suffix if present, show "Open Position" for position IDs)
filtered['Clean Name'] = filtered['Name'].apply(
    lambda x: 'Open Position' if str(x).startswith('POS') else (x.split('(')[0].strip() if '(' in str(x) else x)
)

# Sort results
filtered = filtered.sort_values(['<SORT_COL>', 'Clean Name'])

# Display results
unique_count = filtered['EEID'].nunique()
print(f'Results: {unique_count} unique people')
print()
print(filtered[['Clean Name', 'F3 Function', 'Workload', scope_col, 'Sales Region']].to_string(index=False))
```

## Key Reference Values

### F3 Function Values
- `AFE` - Applied Field Engineer (individual contributor)
- `AFE Mgmt` - AFE Manager
- `Field CTO` - Field CTO (individual contributor)
- `Field CTO Mgmt` - Field CTO Manager
- `Data Cloud Specialist` - Data Cloud Specialist
- `AI Specialist`, `Solution Innovation` - Other specialist roles

### Workload Values
- `AI/ML` - AI/ML workload
- `ML` - Machine Learning specific
- `Data Engineering` - Data Engineering workload
- `OLTP` - OLTP workload
- `Analytics` - Analytics workload
- `Apps & Collab` - Applications & Collaboration

### Sales Scope (Market or Theater) Values
- `AMS` - Americas (pooled)
- `USMajors` - US Major accounts (with specific regions)
- `AMSExpansion` - Americas Expansion
- `AMSAcquisition` - Americas Acquisition
- `USPubSec` - US Public Sector
- `EMEA` - Europe/Middle East/Africa
- `APJ` - Asia Pacific Japan

### Sales Region Values
- `Pooled` - Pooled across all regions in scope
- `FSI`, `FSIGlobals` - Financial Services
- `HCLS` - Healthcare & Life Sciences
- `MFG` - Manufacturing
- `RCG` - Retail & Consumer Goods
- `TMT` - Technology, Media, Telecom
- `Federal`, `SLED` - Government
- `LATAM`, `CanadaExp` - Geographic regions
- Various expansion regions: `NortheastExp`, `SouthwestExp`, etc.

## Output Format

Present results as a markdown table with:
1. Count of unique people and total assignments
2. Table with requested columns (Name, F3 Function, Workload, Sales Scope, Sales Region)
3. Summary by key groupings if relevant

**Example Output:**
```
## AFEs Supporting Data Engineering in USMajors-RCG or AMS Pooled (No Managers): 7

| Name | F3 Function | Workload | Sales Scope | Sales Region |
|------|-------------|----------|-------------|--------------|
| Jason Hughes | AFE | Data Engineering | AMS | Pooled |
| Marc Henderson | AFE | Data Engineering | USMajors | RCG |
...

**Summary:**
- **6 AFEs** in AMS Pooled
- **1 AFE** (Marc Henderson) in USMajors - RCG
```

## Common Query Patterns

### "Who supports AI/ML in AMS or USMajors"
Filter: `Workload contains AI|ML` AND `Scope in [AMS, USMajors]`

### "Which AFEs support RCG"
Filter: `F3 Function = AFE` AND `Sales Region = RCG`

### "List specialists in USMajors (no managers)"
Filter: `F3 Function = <type>` (not containing Mgmt) AND `Scope = USMajors`

### "Who supports [Scope] - [Region]" (e.g., "USMajors - RCG")
Filter: `Scope = USMajors` AND `Sales Region = RCG`

## Notes

- Always check column names first - they vary between file versions
- `EEID.notna()` filters out open positions/placeholder rows
- Some files have `Sales Scope - Market or Theater`, others have separate `Market or Theater` and `Sales Scope` columns
- "Pooled" region means the person supports all regions within their scope
- USMajors always has specific regions (FSI, HCLS, etc.), not Pooled
