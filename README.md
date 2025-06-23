# PhotoSorter
PhotoSorter is a  command-line tool written in Swift to organise photos. It finds all photos in a folder with a specified Finder tag, and moves it and its accompanying RAW file to a separate folder. 

I wrote this tool to help speed up my workflow when sorting through my photography. I found the combination of Swift, Foundation, and ArgumentParser a fast, native, and ergonomic way to work with the Mac file system.

## Requirements

- macOS (because it relies on Finder tags)
- Swift 5.3 or later
- Command Line Tools installed

## Installation

Clone this repository and build the executable:

```bash
git clone https://github.com/AdityaMuthukattu/PhotoSorter.git
cd PhotoSorter
swift build -c release
```

The executable will be located at `.build/release/PhotoSorter`.

## Usage

```txt
USAGE: photo-sorter --source <source> --destination <destination> --tag <tag> [--copy] [--dry-run]

OPTIONS:
  -s, --source <source>   Source directory path.
  -d, --destination <destination>
                          Destination directory path.
  -t, --tag <tag>         Finder tag to match.
  --copy                  Copy files instead of moving.
  --dry-run               Preview files to be moved without making changes.
  -h, --help
```
## Examples

Move all photos and corresponding RAW files tagged "toEdit"

```bash
photo-sorter -s ~/Pictures/import -d ~/Pictures/edit -t toEdit
```

Copy all photos (and RAWs) marked as "forMichael" to a folder on the Desktop

```bash
photo-sorter -s ~/Pictures/edit -d ~/Desktop/SendToMichael -t forMichael --copy
```
