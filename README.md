# Academic Document Template

This repository provides a simple and unsophisticated integrated suite of files for open academic and technical writing using Quarto, tailored to users without a specialist data science (or even computer science) background. It's designed to streamline the process of creating professional academic documents while maintaining flexibility in output formats and styling.

Working example: <https://sustainabledevelopmentreform.github.io/Technical-Publishing/>

## What This Template Does

At its core, this template offers a unified approach to academic document preparation. Rather than managing multiple separate files and formats, you work with a single set of markdown files that can generate various outputs (HTML, Word, PDF via Typst) while maintaining consistent styling and structure.

The template combines: - A main Quarto markdown document (`index.qmd`) - Supporting layout and style files - Configuration files that handle the technical details of document formatting - Example content demonstrating advanced features like cross-references, citations, and complex figures

## Using the Template

The simplest way to use this template is to: 1. Clone or download the repository 2. Edit `index.qmd` in your preferred editor 3. Use the terminal command `quarto publish gh-pages` to publish

All the files work together as an integrated package - you generally only need to modify the main document and let the supporting files handle the formatting details. The code includes detailed comments explaining how each component works; look there for technical details about specific features.

## Publishing and Current Status

The template is designed to work with GitHub Pages for easy sharing of your documents. While the basic workflow is straightforward, there is currently an unresolved issue where automatic publishing upon repository commits is not functioning as expected. Until this is resolved, manual publishing using the terminal command is recommended.

## Local dependencies (and links)

* [Quarto and Documentation](https://quarto.org)
* [RStudio](https://posit.co/download/rstudio-desktop/)
* [VS Code](https://code.visualstudio.com)
* [Python](https://www.python.org/downloads/)
* [R Project for Statistical Computing](https://www.r-project.org)

## Technical Details

The template inherits its licensing terms from the underlying code libraries it uses (Quarto, Typst, etc.). This ensures compatibility while respecting the original licenses of these components.

The code is extensively commented throughout all files, providing detailed explanations of: - Configuration options - Format-specific features - Styling controls - Integration points between components

If you need to modify the template's behavior, these comments will guide you through the process.

------------------------------------------------------------------------

*Note: This is a working template - feedback and contributions are welcome as we continue to improve its functionality.*
