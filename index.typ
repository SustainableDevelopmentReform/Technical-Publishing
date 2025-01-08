// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let unescape-eval(str) = {
  return eval(str.replace("\\", ""))
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "linux libertine",
  fontsize: 11pt,
  table-fontsize: 0.5em, // BM Hack
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "linux libertine",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering) // (BM this is original)
  
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    block(inset: 2em)[
      #for (i, author) in authors.enumerate() {
        [*#author.name*]
        if author.affiliation != "" [, #author.affiliation]
        if author.email != "" [, #author.email]
        if i < authors.len() - 1 [
          #linebreak()
        ]
      }
    ]
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
#set bibliography(title: "References")
#set table(
  stroke: (
    x: .1pt,
    y: .1pt
  ),
  fill: (x, y) => if y == 0 { rgb(245, 245, 245) }
)
#show table: it => {
  set text(size: 7pt)
  set par (
    justify: false
  )
  it
}
#show heading: it => [
  #it
  #v(0.6em)
]
#show figure.caption: set align(left)
#show footnote.entry: it => {
  set par(first-line-indent: 0em)
  [#h(-1em)#it]  // Pulls the number back
}
#import "@preview/fontawesome:0.1.0": *

#show: doc => article(
  title: [Example Document Template],
  authors: (
    ( name: [Primary Author],
      affiliation: [Department Name, Institution Name],
      email: [] ),
    ( name: [Second Author],
      affiliation: [Department Name, Institution Name],
      email: [author\@institution.edu] ),
    ),
  date: [2024-12-20],
  abstract: [This template demonstrates the capabilities of Quarto for academic writing. It shows how to create complex documents with figures, tables, citations, and specialized formatting. The template supports multiple output formats including HTML, Word, and PDF via Typst.

],
  abstract-title: "Summary:",
  margin: (bottom: 2cm,left: 2cm,right: 2cm,top: 2cm,),
  paper: "a4",
  fontsize: 10pt,
  sectionnumbering: "1.1.1",
  toc: true,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= Key findings
<key-findings>
- This template demonstrates effective academic document structure. Key findings should summarize main points in clear, concise language. Each bullet point should be substantive and typically 2-3 sentences long.

- Complex features can be demonstrated throughout, such as cross-references (see @fig-example), citations @capitals_coalition_2024, and footnotes#footnote[Footnotes can be placed inline or collected at the end.];. These features work across all output formats including HTML, Word and PDF.

- Multi-level bullets work as follows:

  - Sub-points should provide supporting detail

  - They can include citations @tnfd_2024

  - Second-level points with spacing between them are also possible:

    - Third level bullets demonstrate deeper hierarchy
    - With multiple points as needed

#figure([
#box(image("media/picture 1.png"))
], caption: figure.caption(
position: bottom, 
[
Example figure showing conceptual relationships. Place figures in the media/ folder.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-example>


= Introduction
<sec-introduction>
+ This template uses numbered paragraphs for the main sections. Paragraphs should be concise and focused on a single main point or idea. Citations can be included @gri2021@tnfd_2024 and will be rendered according to the specified citation style.

+ Images can be included as either figures with captions (as above) or inline. Code blocks and other technical content can be included:

  ```python
  def example_function():
      """Demonstrates code inclusion."""
      return "Hello world"
  ```

+ Tables can be included in several ways. Here’s an R-generated table:

#figure([
#table(
  columns: 3,
  align: (left,left,left,),
  table.header([Category], [Value], [Description],),
  table.hline(),
  [A], [10], [First],
  [B], [20], [Second],
  [C], [30], [Third],
)
], caption: figure.caption(
position: top, 
[
Example table showing data organization
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-example>


= Advanced Document Features
<advanced-document-features>
== Complex Tables and Formatting
<sec-tables>
+ Complex tables can include multiple header levels, custom formatting, and footnotes. Here’s an example using the `kable` function with custom CSS:

#block[
#figure([
#table(
  columns: 5,
  align: (left,left,left,left,left,),
  table.header([Category], [Description], [Value1], [Value2], [Notes],),
  table.hline(),
  [Type A], [Complex description with details], [10.5], [45.2], [Special case\*],
  [Type B], [Another detailed description], [20.3], [33.1], [Standard],
  [Type C], [Third detailed element], [15.7], [28.9], [Modified†],
)
], caption: figure.caption(
position: top, 
[
Demonstration of Complex Table Formatting
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-complex>


]
- Indicates special condition † Modified calculation applied

== Callout Boxes and Special Content
<sec-callouts>
+ Callout boxes can highlight important information:

#block[
#callout(
body: 
[
This is an example note callout. It can contain:

- Bullet points
- #emph[Formatted text]
- Even `code snippets`

]
, 
title: 
[
Important Note Title
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
#block[
#callout(
body: 
[
Warning callouts use different styling and icons.

]
, 
title: 
[
Caution
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
)
]
#block[
#callout(
body: 
[
Tips use a different style and icon.

]
, 
title: 
[
Suggestion
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
)
]
== Multi-Panel Figures
<sec-figures>
+ Complex figures can combine multiple panels with individual captions:

#quarto_super(
kind: 
"quarto-float-fig"
, 
caption: 
[
Multi-panel figure demonstration
]
, 
label: 
<fig-panels>
, 
position: 
bottom
, 
supplement: 
"Figure"
, 
subrefnumbering: 
"1a"
, 
subcapnumbering: 
"(a)"
, 
[
#grid(columns: 2, gutter: 2em,
  [
#block[
#figure([
#box(image("index_files/figure-typst/fig-panels-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Panel A shows first element
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-panels-1>


]
],
  [
#block[
#figure([
#box(image("index_files/figure-typst/fig-panels-2.svg"))
], caption: figure.caption(
position: bottom, 
[
Panel B shows second element
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-panels-2>


]
],
)
]
)
== Advanced Cross-Referencing
<sec-cross-ref>
+ Cross-references can be used for various elements:
  - Figures: See @fig-panels for a multi-panel example
  - Tables: As shown in @tbl-complex
  - Equations: Reference equation @eq-example below
  - Sections: Refer to earlier section on tables (\#sec-tables)
+ Mathematical equations can be numbered and referenced:

#math.equation(block: true, numbering: "(1)", [ $ f (x) = a x^2 + b x + c $ ])<eq-example>

#block[
#set enum(numbering: "1.", start: 3)
+ Inline mathematics can use single dollar signs: $E = m c^2$
]

== Document Infrastructure
<sec-infrastructure>
+ This template supports:
  - Automatic table of contents generation
  - List of figures and tables
  - Custom header and footer content
  - Bibliography management
  - Multiple citation styles @gri2021@tnfd_2024
+ Example of a complex citation block:

#block[
#callout(
body: 
[
According to #cite(<capitals_coalition_2024>, form: "prose", supplement: [p.~23]);, this specific method has several advantages. Multiple citations can be combined @tnfd_2024@tcfd_2024, and page numbers can be included @gri2021[pp.~15-17].

]
, 
title: 
[
Citation Example
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
== Interactive Elements
<sec-interactive>
+ When outputting to HTML, interactive elements can be included:

== Appendix
<sec-appendix>
Additional tables and supplementary information can be included here. The template supports multiple appendices and complex table layouts:

#block[
#figure([
#table(
  columns: 3,
  align: (left,left,left,),
  table.header([Category], [Description], [Value],),
  table.hline(),
  [Type 1], [Detailed example text], [High],
  [Type 2], [More example content], [Medium],
  [Type 3], [Final example entry], [Low],
)
], caption: figure.caption(
position: top, 
[
Example Appendix Table
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-appendix>


]
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
[
Appendix
]
)
]
Note that references need to be included in BibTex format in the relevant file (references.bib)

#block[
] <refs>




#bibliography("references.bib")

