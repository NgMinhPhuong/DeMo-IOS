#!/usr/bin/env python3
"""Clean up duplicate groups and children in pbxproj after a partial transformation."""
import re

PBXPROJ = "/Users/macos/Desktop/prj-promax/prj-promax.xcodeproj/project.pbxproj"

with open(PBXPROJ) as f:
    content = f.read()

# New group UUIDs
NEW_UUIDS = [
    "22DB7C462FB6C47A005697DF",  # Models
    "22DB7C472FB6C47A005697DF",  # Data
    "22DB7C482FB6C47A005697DF",  # Realm
    "22DB7C492FB6C47A005697DF",  # Repos
    "22DB7C4A2FB6C47A005697DF",  # Domain
    "22DB7C4B2FB6C47A005697DF",  # UseCases
    "22DB7C4C2FB6C47A005697DF",  # Coord
    "22DB7C4D2FB6C47A005697DF",  # Services
    "22DB7C4E2FB6C47A005697DF",  # ViewModels
    "22DB7C4F2FB6C47A005697DF",  # Views
]

# Step 1: Deduplicate children in the main prj-promax group
# The main group is defined at 22DB7BEE
# Find the children section and remove duplicate lines
main_group_start = content.find('\t\t22DB7BEE2FB6C477005697DF /* prj-promax */ = {')
group_end = content.find('\t\t};', main_group_start)
children_section = content[main_group_start:group_end]

# Find the children block
children_start = children_section.find('children = (')
children_end = children_section.find('\t\t);', children_start)

before_children = children_section[:children_start + len('children = (')]
after_children_marker = children_section[children_end:]

children_block = children_section[children_start + len('children = ('):children_end]

# Split into individual child entries
lines = children_block.strip().split('\n')
seen = set()
unique_lines = []
for line in lines:
    stripped = line.strip()
    # Extract UUID
    uuid_match = re.match(r'([0-9A-F]{24})', stripped)
    if uuid_match:
        uuid = uuid_match.group(1)
        if uuid not in seen:
            seen.add(uuid)
            unique_lines.append(line)
    else:
        unique_lines.append(line)

new_children_block = '\n' + '\n'.join(unique_lines) + '\n\t\t'
new_children_section = before_children + new_children_block + after_children_marker
content = content[:main_group_start] + new_children_section + content[group_end:]

# Step 2: Deduplicate group definitions in PBXGroup section
# Find the PBXGroup section
group_section_start = content.find('/* Begin PBXGroup section */')
group_section_end = content.find('/* End PBXGroup section */')
group_section = content[group_section_start:group_section_end]

# For each new UUID, keep only the LAST occurrence (most complete definition)
for uuid in NEW_UUIDS:
    # Find all occurrences of the group definition
    pattern = re.compile(r'(\t\t' + uuid + r' /\*[^*]*\*/ = \{[^}]*\};)', re.DOTALL)
    matches = list(pattern.finditer(group_section))
    if len(matches) > 1:
        # Remove all but the last occurrence
        for m in matches[:-1]:
            group_section = group_section.replace(m.group(0), '', 1)
        # Remove the extra blank lines left behind
        group_section = re.sub(r'\n{3,}', '\n\n', group_section)

content = content[:group_section_start] + group_section + content[group_section_end:]

with open(PBXPROJ, 'w') as f:
    f.write(content)

print("Cleanup done!")
