param (
  $org = "nexi-intra",
  $repo = "koksmat-captain",
  $cleanGitClone = $true,
  $cleanLocalDocs = $true
)
# Define the output directory
$docsRootDir = Join-Path $env:workdir 'docs' $org $repo
$docsDir = Join-Path $docsRootDir 'output'
# Ensure the docs directory exists; create it if it doesn't
if (-not (Test-Path -Path $docsRootDir)) {
  try {
    New-Item -Path $docsRootDir -ItemType Directory -Force | Out-Null
    Write-Verbose "Created directory: $docsRootDir"
  }
  catch {
    Write-Error "Failed to create directory $docsRootDir. $_"
    exit 1
  }
}

Set-Location $docsRootDir

$repodir = Join-Path $docsRootDir "repo"

if (Test-Path -Path $repodir) {
  if ($cleanGitClone) {
    Remove-Item -Path $repodir -Recurse -Force
    gh repo clone $org/$repo "repo"  -- --depth=1
  }
}
else {
  gh repo clone $org/$repo "repo" -- --depth=1
}
<#
Now that we have the repository cloned, we can start looking for files that we like to process
#>
Set-Location $repodir


# Retrieve all *.ps1 files recursively from the current directory
try {
  $runScripts = Get-ChildItem -Path . -Recurse -Filter '*.ps1' -Exclude 'debug.ps1', 'temp.ps1'.'.*.ps1'  -File
  Write-Verbose "Found $($runScripts.Count) .ps1 files."
}
catch {
  Write-Error "Error while searching for run.ps1 files. $_"
  exit 1
}

# Define a variable for triple backticks to avoid issues
$tripleBackticks = '```'

# Function to parse run.ps1 content into code and markdown segments

if (Test-Path -Path $docsDir) {
  if ($cleanLocalDocs) {
    Remove-Item -Path $docsDir -Recurse -Force
  }
}
write-host "Copying images to" $docsDir
# Define the File Extensions to Copy
$extensions = "*.png", "*.gif", "*.jpg", "*.md", "*.mdx"

# Retrieve and Copy the Files
Get-ChildItem -Path $repodir -Recurse -Include $extensions -File | ForEach-Object {
  # Determine the Relative Path of the File 
  $relativePath = $_.FullName.Substring($repodir.Length).TrimStart('\')

  # Determine the Destination Path
  $destinationPath = Join-Path $docsDir $relativePath

  # Get the Destination Directory Path
  $destinationDir = Split-Path -Path $destinationPath -Parent

  # Ensure the Destination Subdirectory Exists
  if (!(Test-Path -Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    Write-Host "Created directory: $destinationDir"
  }

  # Copy the File to the Destination Path
  Copy-Item -Path $_.FullName -Destination $destinationPath -Force -Verbose
}


# Process each run.ps1 file to create an individual Markdown file
foreach ($script in $runScripts) {
  # Get the directory of the run.ps1 file
  $fileDir = $script.Directory

  # Compute the relative path from the current directory to the file's directory
  $currentPath = (Get-Location).Path
  $fullFilePath = $fileDir.FullName
  $baseFileName = $script.BaseName

  # Handle different path formats (Windows vs. Unix)
  $relativePath = $fullFilePath.Substring($currentPath.Length).TrimStart('\', '/')

  # Calculate the entry name
  # if ([string]::IsNullOrEmpty($relativePath)) {
  #   # If run.ps1 is in the current directory
  #   $calculatedName = $baseFileName
  # }
  # else {
  #   # Replace backslashes or forward slashes with dashes and append '-run'
  #   $calculatedName = ($relativePath -replace '[\\/]', '-') + '-' + $baseFileName
  # }
  $calculatedName = $script.Name
  # Define the Markdown file name
  $markdownFileName = "$calculatedName.md"
  if ($markdownFileName -eq "run.ps1.md") {
    $markdownFileName = "index.md"
  }

  # Define the relative directory for the markdown file within docs
  $markdownRelativeDir = if ([string]::IsNullOrEmpty($relativePath)) {
    ''
  }
  else {
    $relativePath -replace '[\\/]', '\'
  }

  # Create the full path for the markdown file's directory
  $markdownFullDir = if ([string]::IsNullOrEmpty($markdownRelativeDir)) {
    $docsDir
  }
  else {
    Join-Path $docsDir $markdownRelativeDir
  }
  #$markdownFullDir = $docsDir
  # Ensure the directory exists
  if (-not (Test-Path -Path $markdownFullDir)) {
    try {
      New-Item -Path $markdownFullDir -ItemType Directory -Force | Out-Null
      Write-Verbose "Created directory: $markdownFullDir"
    }
    catch {
      Write-Error "Failed to create directory $markdownFullDir. $_"
      continue
    }
  }

  # Define the full Markdown file path within the subdirectory
  $markdownFilePath = Join-Path $markdownFullDir $markdownFileName 

  # Read the content of the run.ps1 file
  try {
    $scriptContent = Get-Content -Path $script.FullName -Raw
  }
  catch {
    Write-Error "Failed to read file $($script.FullName). $_"
    continue
  }

  # Extract metadata for front matter
  # Title: Calculated name
  $title = $calculatedName

  # Date: Last write time of the run.ps1 file in ISO 8601 format
  $date = $script.LastWriteTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

  # Description: Extract the first comment line or set a default description
  $description = ""
  $firstLine = $scriptContent -split "`n" | Select-Object -First 1
  if ($firstLine -match '^#\s*(.+)') {
    $description = $matches[1].Trim()
  }
  else {
    $description = "Description for $calculatedName."
  }

  # Tags: Default tags or based on directory structure
  $tags = @("run", "script")
  if ($relativePath) {
    $pathParts = $relativePath -split '[\\/]'
    $tags += $pathParts
  }

  # Author: Attempt to extract from script comments or set to 'Unknown'
  $author = "Unknown"
  $authorLine = $scriptContent -split "`n" | Where-Object { $_ -match '^#\s*Author:\s*(.+)' } | Select-Object -First 1
  if ($authorLine -and $authorLine -match '^#\s*Author:\s*(.+)') {
    $author = $matches[1].Trim()
  }


  # Parse the script content into segments
  write-host "Parsing $($script.FullName)"
  . "$PSScriptRoot/parse-powershell.ps1"
  $parseResult = Parse-PowerShell -Content $scriptContent
  $segments = $parseResult.Segments
  $frontMatter = $parseResult.FrontMatter
  if ($frontMatter.title) {
    $title = $frontMatter.title
   
  }

  

  # Initialize an array to hold the formatted Markdown content
  $formattedContent = @()

  foreach ($segment in $segments) {
    if ($segment.Type -eq 'Code') {
      # Add PowerShell code block
      $formattedContent += "$($tripleBackticks)powershell"
      $formattedContent += $segment.Content.TrimEnd()
      $formattedContent += "$tripleBackticks`n"
    }
    elseif ($segment.Type -eq 'Markdown') {
      # Add Markdown content (trim to remove any leading/trailing whitespace)
      $formattedContent += $segment.Content.Trim()
      $formattedContent += "`n"
    }
  }

  # Prepare the tags string for front matter
  #$tagsString = $tags | ForEach-Object { "`"`"$_`"`" } -join ', '

  # Prepare the Markdown front matter with expanded metadata
  $markdownFrontMatter = @"
---
title: "$title"
description: "$description"
tags: [$tagsString]
author: "$author"
---
`n
"@

  # Combine front matter and formatted content
  $fullMarkdownContent = $markdownFrontMatter + ($formattedContent -join "`n")

  # Write the Markdown content to the file
  try {
    Set-Content -Path $markdownFilePath -Value $fullMarkdownContent -Encoding UTF8
    Write-Host "Created Markdown file: $markdownFilePath"
  }
  catch {
    Write-Error "Failed to write to file $markdownFilePath. $_"
  }
}
