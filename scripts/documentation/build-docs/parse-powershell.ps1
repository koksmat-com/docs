function Extract-EnvVars {
  param (
    [string]$CodeContent
  )

  # Define the regex pattern to match $env:VARIABLE
  $envVarPattern = '\$env:([A-Za-z_][A-Za-z0-9_]*)'

  # Use regex to find all matches and extract the variable names
  $matches = [regex]::Matches($CodeContent, $envVarPattern)

  # Extract the variable names, sort them, and remove duplicates
  $envVars = $matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

  return $envVars
}

function Extract-FrontMatter {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$Content
  )

  # Define front matter markers
  $frontMatterStart = '<#---'
  $frontMatterEnd = '---'

  # Initialize hashtable for front matter
  $frontMatter = @{}

  # Check if content starts with <#---
  if ($Content.StartsWith($frontMatterStart)) {
    # Find the end of the front matter
    $startIndex = $Content.IndexOf($frontMatterStart) + $frontMatterStart.Length
    $endIndex = $Content.IndexOf($frontMatterEnd, $startIndex)

    if ($endIndex -eq -1) {
      throw "Front matter starts with <#--- but does not end with ---."
    }

    # Extract front matter block
    $frontMatterBlock = $Content.Substring($startIndex, $endIndex - $startIndex).Trim()

    # Split front matter into lines
    $lines = $frontMatterBlock -split "`n"

    # Initialize variables for multi-line values
    $currentKey = $null
    $isMultiLine = $false
    $multiLineValue = ""

    foreach ($line in $lines) {
      $trimmedLine = $line.Trim()

      # Skip empty lines
      if ([string]::IsNullOrWhiteSpace($trimmedLine)) {
        continue
      }

      if ($isMultiLine) {
        # Check for closing quote
        if ($trimmedLine.EndsWith('"')) {
          $multiLineValue += "`n" + $trimmedLine.TrimEnd('"')
          $frontMatter[$currentKey] = $multiLineValue
          $isMultiLine = $false
          $currentKey = $null
        }
        else {
          $multiLineValue += "`n" + $trimmedLine
        }
      }
      else {
        # Match key: value pattern
        if ($trimmedLine -match '^(\w+):\s*"(.*)"$') {
          # Single-line value enclosed in quotes
          $key = $matches[1]
          $value = $matches[2]
          $frontMatter[$key] = $value
        }
        elseif ($trimmedLine -match '^(\w+):\s*"(.*)$') {
          # Multi-line value starts
          $key = $matches[1]
          $valueStart = $matches[2]
          $currentKey = $key
          $multiLineValue = $valueStart
          $isMultiLine = $true
        }
        elseif ($trimmedLine -match '^(\w+):\s*(.*)$') {
          # Single-line value without quotes
          $key = $matches[1]
          $value = $matches[2]
          $frontMatter[$key] = $value.Trim('"')  # Remove quotes if present
        }
        else {
          Write-Warning "Unrecognized front matter line: $line"
        }
      }
    }

    # Extract the remaining content after the front matter
    $remainingContent = $Content.Substring($endIndex + $frontMatterEnd.Length).TrimStart()
    if ($remainingContent.StartsWith("#>")) {
      $remainingContent = $Content.Substring($endIndex + $frontMatterEnd.Length + 2).TrimStart()
    }
    else {
      if ($Content.StartsWith($frontMatterStart)) {
        $remainingContent = "<#`n" + $Content.Substring($endIndex + $frontMatterEnd.Length).TrimStart()
      }
      
    }


    return @{
      FrontMatter = $frontMatter
      Content     = $remainingContent
    }
  }
  else {
    return @{
      FrontMatter = @{}
      Content     = $Content
    }
  }
}

function Parse-PowerShell {
  param (
    [string]$Content = @"
<#---
title: Parse PowerShell
---

#>
<# 
Hello, this is a markdown block.
#>
Write-Host 'Hello, this is code.'
\$env:FOO 
\$env:BAR
# Another comment
\$env:BAZ
"@
  )

  $result = Extract-FrontMatter -Content $Content
  $FrontMatter = $result.FrontMatter
  $Content = $result.Content
  # Initialize an array to hold the segments
  $segments = @()

  # Define regex patterns
  $markdownStartPattern = '<#'
  $markdownEndPattern = '#>'

  # Initialize state variables
  $currentIndex = 0
  $isMarkdown = $false

  while ($currentIndex -lt $Content.Length) {
    if (-not $isMarkdown) {
      # Look for the start of a markdown block
      $start = $Content.IndexOf($markdownStartPattern, $currentIndex)
      if ($start -eq -1) {
        # No more markdown blocks; add the rest as code
        $segments += [PSCustomObject]@{ Type = 'Code'; Content = $Content.Substring($currentIndex) }
        break
      }
      else {
        if ($start -gt $currentIndex) {
          # Add code before the markdown block
          $codeSegment = $Content.Substring($currentIndex, $start - $currentIndex)
          $segments += [PSCustomObject]@{ Type = 'Code'; Content = $codeSegment }
        }
        # Update currentIndex to after the start marker
        $currentIndex = $start + $markdownStartPattern.Length
        $isMarkdown = $true
      }
    }
    else {
      # Look for the end of the markdown block
      $end = $Content.IndexOf($markdownEndPattern, $currentIndex)
      if ($end -eq -1) {
        # No end marker found; treat the rest as markdown
        $markdownSegment = $Content.Substring($currentIndex)
        $segments += [PSCustomObject]@{ Type = 'Markdown'; Content = $markdownSegment }
        break
      }
      else {
        # Extract markdown content
        $markdownSegment = $Content.Substring($currentIndex, $end - $currentIndex)
        $segments += [PSCustomObject]@{ Type = 'Markdown'; Content = $markdownSegment }
        # Update currentIndex to after the end marker
        $currentIndex = $end + $markdownEndPattern.Length
        $isMarkdown = $false
      }
    }
  }

  # Extract all $env: variables from code segments using regex
  $envVarPattern = '\$env:([A-Za-z_][A-Za-z0-9_]*)'
  $envVars = $segments |
  Where-Object { $_.Type -eq 'Code' } |
  ForEach-Object {
    $_.Content -match $envVarPattern | Out-Null
    [regex]::Matches($_.Content, $envVarPattern) | ForEach-Object { $_.Groups[1].Value }
  } |
  Sort-Object -Unique

  # Create markdown table
  if ($envVars.Count -gt 0) {
    $markdownTable = @"
### Environment Variables Used

| Environment Variable |
|----------------------|
"@

    foreach ($var in $envVars) {
      $markdownTable += "| $var |`n"
    }

    # Add the markdown table as a new markdown segment
    $segments += [PSCustomObject]@{ Type = 'Markdown'; Content = $markdownTable }
  }
  return @{
    FrontMatter = $FrontMatter
    Segments    = $segments
  }
  
}

