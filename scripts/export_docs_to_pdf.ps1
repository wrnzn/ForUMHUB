# Export docs to PDF using pandoc
# Requires pandoc and a LaTeX engine (e.g., miktex or texlive)

param(
  [string]$input = "docs/Project_Documentation.md",
  [string]$output = "docs/ForUMhub_Documentation.pdf"
)

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
  Write-Error "Pandoc is not installed. Please install pandoc and a LaTeX engine (e.g., MiKTeX or TeX Live)."
  exit 1
}

pandoc $input -o $output --pdf-engine=xelatex --metadata title="ForUMhub Documentation"
Write-Host "Exported $input to $output"