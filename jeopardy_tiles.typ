// Configuration for grid and layout
#let cols = 2
#let rows = 3
#let page-margin = 0in

#let qa_side_text_size = 12pt
#let category_text_size = 30pt
#let money_text_size = 50pt

#set page(
  paper: "us-letter",
  margin: page-margin,
)

// Calculate card sizes automatically based on page dimensions and grid settings
#let card-width = (100% / cols)
#let card-height = (100% / rows)

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
      let (category, round, value, question, answer) = row
      card-box(
        align(center + horizon)[
          #text(round, qa_side_text_size)
          #divider()
          #text(size: category_text_size, weight: "bold", upper(category))
          #divider()
          #text(size: money_text_size, weight: "extrabold", "$" + value)
        ],
      )
    })
  )

  // --- BACK SIDE PAGE (Horizontally flipped grid order for double-sided printing) ---
  pagebreak(weak: true)

  let row-chunks = chunk.chunks(cols)
  let back-chunk = ()
  for r in row-chunks {
    let reversed-row = r.rev()
    while reversed-row.len() < cols {
      reversed-row.push(("-", "-", "", ""))
    }
    for card in reversed-row {
      back-chunk.push(card)
    }
  }

  grid(
    columns: (1fr,) * cols,
    rows: (1fr,) * rows,
    gutter: 0pt,
    ..back-chunk.map(row => {
      let (category, round, value, question, answer) = row
      if category == "-" {
        card-box([]) // Blank card padding
      } else {
        card-box(
          align(center + horizon)[
            #text(size: qa_side_text_size, weight: "medium", question)
            #line(length: 80%, stroke: 0.5pt + luma(120))
            #text(size: qa_side_text_size, weight: "bold", style: "italic", answer)
          ],
        )
      }
    })
  )
}
