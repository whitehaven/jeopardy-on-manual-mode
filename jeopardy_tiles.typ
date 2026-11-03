// Configuration for grid and layout
#let cols = 2
#let rows = 3
#let page-margin = 0.5in

#set page(
  paper: "us-letter",
  margin: page-margin,
)

// Calculate card sizes automatically based on page dimensions and grid settings
#let card-width = (100% / cols)
#let card-height = (100% / rows)

// Sample inline CSV data (replace csv.decode(...) with csv("questions.csv") for external files)
#let csv-data = csv("questions.csv")

// Extract header and content rows
#let headers = csv-data.first()
#let records = csv-data.slice(1)

// Helper to chunk records into page-sized groups
#let cards-per-page = cols * rows
#let record-chunks = records.chunks(cards-per-page)

// Helper to render a card border and styling
#let card-box(content, fill-color: white) = {
  rect(
    width: 100%,
    height: 100%,
    stroke: (dash: "dashed", paint: luma(150), thickness: 0.5pt),
    fill: fill-color,
    inset: 12pt,
    content,
  )
}

// Loop through each page chunk
#for chunk in record-chunks {
  // --- FRONT SIDE PAGE ---
  pagebreak(weak: true)
  grid(
    columns: (1fr,) * cols,
    rows: (1fr,) * rows,
    gutter: 0pt,
    ..chunk.map(row => {
      let (category, value, question, answer) = row
      card-box(
        align(center + horizon)[
          #text(size: 14pt, weight: "bold", font: "Liberation Sans", upper(category))
          #v(10pt)
          #text(size: 28pt, weight: "extrabold", fill: rgb("#d4af37"), font: "Liberation Sans", "$" + value)
        ],
        fill-color: rgb("#060ce9").lighten(90%),
      )
    })
  )

  // --- BACK SIDE PAGE (Horizontally flipped grid order for double-sided printing) ---
  pagebreak(weak: true)

  // Reverse columns per row so back sides align with front sides when flipped along long edge
  let back-rows = ()
  let row-chunks = chunk.chunks(cols)
  for r in row-chunks {
    // Reverse the cards in the row for back-side alignment
    let reversed-row = r.rev()
    // Pad row if last page is incomplete
    while reversed-row.len() < cols {
      reversed-row.insert(0, ("-", "-", "", ""))
    }
    back-rows.push(reversed-row)
  }
  let back-chunk = back-rows.flatten()

  grid(
    columns: (1fr,) * cols,
    rows: (1fr,) * rows,
    gutter: 0pt,
    ..back-chunk.map(row => {
      let (category, value, question, answer) = row
      if category == "-" {
        card-box([]) // Blank card padding
      } else {
        card-box(
          align(center + horizon)[
            #text(size: 11pt, weight: "medium", question)
            #v(8pt)
            #line(length: 80%, stroke: 0.5pt + luma(120))
            #v(8pt)
            #text(size: 11pt, weight: "bold", style: "italic", fill: rgb("#1a5276"), answer)
          ],
        )
      }
    })
  )
}
