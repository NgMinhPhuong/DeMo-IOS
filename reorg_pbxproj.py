#!/usr/bin/env python3
"""
Reorganize pbxproj groups to match actual folder structure.
"""
import re

PBXPROJ = "/Users/macos/Desktop/prj-promax/prj-promax.xcodeproj/project.pbxproj"

with open(PBXPROJ) as f:
    content = f.read()

# New group UUIDs (verified unused)
G_MODELS    = "22DB7C462FB6C47A005697DF"
G_DATA      = "22DB7C472FB6C47A005697DF"
G_REALM     = "22DB7C482FB6C47A005697DF"
G_REPOS     = "22DB7C492FB6C47A005697DF"
G_DOMAIN    = "22DB7C4A2FB6C47A005697DF"
G_USECASES  = "22DB7C4B2FB6C47A005697DF"
G_COORD     = "22DB7C4C2FB6C47A005697DF"
G_SERVICES  = "22DB7C4D2FB6C47A005697DF"
G_VIEWMODELS = "22DB7C4E2FB6C47A005697DF"
G_VIEWS     = "22DB7C4F2FB6C47A005697DF"

# mapping: UUID -> (new_basename, group_uuid)
FILE_REFS = {
    "22DB7C382FB6C47A005697DF": ("ItemDomain.swift", G_MODELS),
    "22DB7C3A2FB6C47A005697DF": ("RealmItem.swift", G_REALM),
    "22DB7C3C2FB6C47A005697DF": ("RealmService.swift", G_REALM),
    "22DB7C3E2FB6C47A005697DF": ("ItemRepositoryProtocol.swift", G_REPOS),
    "22DB7C402FB6C47A005697DF": ("ItemRepositoryImpl.swift", G_REPOS),
    "22DB7C422FB6C47A005697DF": ("ItemUseCase.swift", G_USECASES),
    "22DB7C442FB6C47A005697DF": ("AppCoordinator.swift", G_COORD),
    "22DB7C242FB6C47A005697DF": ("APIService.swift", G_SERVICES),
    "22DB7C262FB6C47A005697DF": ("ItemViewModel.swift", G_VIEWMODELS),
    "22DB7C282FB6C47A005697DF": ("SettingsViewModel.swift", G_VIEWMODELS),
    "22DB7C2A2FB6C47A005697DF": ("HomeView.swift", G_VIEWS),
    "22DB7C2C2FB6C47A005697DF": ("ItemListView.swift", G_VIEWS),
    "22DB7C2E2FB6C47A005697DF": ("ItemDetailView.swift", G_VIEWS),
    "22DB7C302FB6C47A005697DF": ("AddEditItemView.swift", G_VIEWS),
    "22DB7C322FB6C47A005697DF": ("GridView.swift", G_VIEWS),
    "22DB7C342FB6C47A005697DF": ("SettingsView.swift", G_VIEWS),
    "22DB7C362FB6C47A005697DF": ("CustomImageView.swift", G_VIEWS),
}

# --- Step 1: Remove old flat children from main prj-promax group ---
# The children list in main group has lines like:
#   22DB7C242FB6C47A005697DF /* Services/APIService.swift */,
# We match by UUID, then any non-newline content, then the trailing comma+newline
for uuid, _, _ in [(u, *v) for u, v in FILE_REFS.items()]:
    pattern = rf'(\t\t\t\t{uuid}\s*/\*[^*]*\*/\s*,\n)'
    match = re.search(pattern, content)
    if match:
        content = content.replace(match.group(1), '')
    else:
        print(f"Warning: Could not find child entry for {uuid}")

# --- Step 2: Add new group children to main group ---
# Insert before the Preview Content line
NEW_CHILDREN = [
    f"\t\t\t\t{G_MODELS} /* Models */,",
    f"\t\t\t\t{G_DATA} /* Data */,",
    f"\t\t\t\t{G_DOMAIN} /* Domain */,",
    f"\t\t\t\t{G_COORD} /* Coordinators */,",
    f"\t\t\t\t{G_SERVICES} /* Services */,",
    f"\t\t\t\t{G_VIEWMODELS} /* ViewModels */,",
    f"\t\t\t\t{G_VIEWS} /* Views */,",
]
new_children_block = "\n".join(NEW_CHILDREN) + "\n"
# Find: 22DB7BF52FB6C47A005697DF /* Preview Content */,
preview_marker = r'(\t\t\t\t22DB7BF52FB6C47A005697DF\s*/\* Preview Content \*/\s*,)'
content = re.sub(preview_marker, new_children_block + r"\1", content)

# --- Step 3: Update file paths in PBXFileReference ---
# Pattern: UUID  /* comment */ = {isa = PBXFileReference; ... path = "oldpath"; ... };
for uuid, (new_name, _) in FILE_REFS.items():
    # Match the path value after `path = "` up to `"`
    pattern = rf'({uuid}\s*/\*[^*]*\*/\s*=\s*{{[^}}]*?path\s*=\s*")[^"]+(")'
    content = re.sub(pattern, lambda m: m.group(1) + new_name + m.group(2), content)

# --- Step 4: Update PBXBuildFile display names ---
# e.g.: 22DB7C252FB6C47A005697DF /* Services/APIService.swift in Sources */
# We need to replace the comment part
for uuid, (new_name, _) in FILE_REFS.items():
    pattern = rf'({uuid}\s*/\*\\s*)[^*]+(\s*\*/\s*=)'
    content = re.sub(pattern, lambda m: m.group(1) + new_name + " in Sources" + m.group(2), content)

# --- Step 5: Update fileRef comment references in PBXBuildFile ---
# e.g.: fileRef = 22DB7C24... /* Services/APIService.swift */;
for uuid, (new_name, _) in FILE_REFS.items():
    pattern = rf'(fileRef\s*=\s*{uuid}\s*/\*\\s*)[^*]+(\s*\*/\s*;)'
    content = re.sub(pattern, lambda m: m.group(1) + new_name + m.group(2), content)

# --- Step 6: Insert new group definitions before End PBXGroup section ---
NEW_GROUPS = f"""\t\t{G_MODELS} /* Models */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C382FB6C47A005697DF /* ItemDomain.swift */,
\t\t\t);
\t\t\tpath = Models;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_DATA} /* Data */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{G_REALM} /* Realm */,
\t\t\t\t{G_REPOS} /* Repositories */,
\t\t\t);
\t\t\tpath = Data;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_REALM} /* Realm */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C3A2FB6C47A005697DF /* RealmItem.swift */,
\t\t\t\t22DB7C3C2FB6C47A005697DF /* RealmService.swift */,
\t\t\t);
\t\t\tpath = Realm;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_REPOS} /* Repositories */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C3E2FB6C47A005697DF /* ItemRepositoryProtocol.swift */,
\t\t\t\t22DB7C402FB6C47A005697DF /* ItemRepositoryImpl.swift */,
\t\t\t);
\t\t\tpath = Repositories;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_DOMAIN} /* Domain */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{G_USECASES} /* UseCases */,
\t\t\t);
\t\t\tpath = Domain;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_USECASES} /* UseCases */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C422FB6C47A005697DF /* ItemUseCase.swift */,
\t\t\t);
\t\t\tpath = UseCases;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_COORD} /* Coordinators */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C442FB6C47A005697DF /* AppCoordinator.swift */,
\t\t\t);
\t\t\tpath = Coordinators;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_SERVICES} /* Services */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C242FB6C47A005697DF /* APIService.swift */,
\t\t\t);
\t\t\tpath = Services;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_VIEWMODELS} /* ViewModels */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C262FB6C47A005697DF /* ItemViewModel.swift */,
\t\t\t\t22DB7C282FB6C47A005697DF /* SettingsViewModel.swift */,
\t\t\t);
\t\t\tpath = ViewModels;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{G_VIEWS} /* Views */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t22DB7C2A2FB6C47A005697DF /* HomeView.swift */,
\t\t\t\t22DB7C2C2FB6C47A005697DF /* ItemListView.swift */,
\t\t\t\t22DB7C2E2FB6C47A005697DF /* ItemDetailView.swift */,
\t\t\t\t22DB7C302FB6C47A005697DF /* AddEditItemView.swift */,
\t\t\t\t22DB7C322FB6C47A005697DF /* GridView.swift */,
\t\t\t\t22DB7C342FB6C47A005697DF /* SettingsView.swift */,
\t\t\t\t22DB7C362FB6C47A005697DF /* CustomImageView.swift */,
\t\t\t);
\t\t\tpath = Views;
\t\t\tsourceTree = "<group>";
\t\t}};
"""

content = content.replace("/* End PBXGroup section */", NEW_GROUPS + "\t\t/* End PBXGroup section */")

with open(PBXPROJ, 'w') as f:
    f.write(content)

print("Done! pbxproj has been reorganized.")
